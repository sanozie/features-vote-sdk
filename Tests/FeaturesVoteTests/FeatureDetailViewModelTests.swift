import XCTest
@testable import FeaturesVote

@MainActor
final class FeatureDetailViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        feature: Feature = .fixture(),
        config: Configuration = .fixture(),
        userService: UserService = .anonymous(),
        projectCustomization: Customization? = nil,
        voteService: MockVoteService = MockVoteService(),
        subscriptionService: MockSubscriptionService = MockSubscriptionService()
    ) -> FeatureDetailViewModel {
        FeatureDetailViewModel(
            feature: feature,
            slug: "test",
            voteService: voteService,
            commentService: MockCommentService(),
            subscriptionService: subscriptionService,
            userService: userService,
            configuration: config,
            projectCustomization: projectCustomization
        )
    }

    // MARK: - Anonymous Voting

    func test_requestVote_blockedWhenAnonVotingDisabled() {
        let vm = makeVM(
            config: .fixture(allowAnonymousVoting: false),
            userService: .anonymous()
        )

        vm.requestVote()

        XCTAssertNotNil(vm.permissionError)
        XCTAssertTrue(vm.showPermissionAlert)
        XCTAssertFalse(vm.showVoteConfirmation)
    }

    func test_requestVote_allowedWhenAnonVotingEnabled() async {
        let voteService = MockVoteService()
        let vm = FeatureDetailViewModel(
            feature: .fixture(),
            slug: "test",
            voteService: voteService,
            commentService: MockCommentService(),
            subscriptionService: MockSubscriptionService(),
            userService: .anonymous(),
            configuration: .fixture(allowAnonymousVoting: true, confirmVoting: false)
        )

        vm.requestVote()
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNil(vm.permissionError)
        XCTAssertFalse(vm.showPermissionAlert)
        XCTAssertEqual(voteService.upvoteCallCount, 1, "Upvote should be called")
    }

    func test_requestVote_blockedByProjectIsAnonDisabled() {
        let vm = makeVM(
            config: .fixture(allowAnonymousVoting: true), // local allows
            userService: .anonymous(),
            projectCustomization: .fixture(isAnonDisabled: true) // server blocks
        )

        vm.requestVote()

        XCTAssertNotNil(vm.permissionError)
        XCTAssertTrue(vm.showPermissionAlert)
    }

    // MARK: - Vote Confirmation

    func test_requestVote_confirmationRequired_showsDialog() {
        let voteService = MockVoteService()
        let vm = makeVM(
            config: .fixture(confirmVoting: true),
            userService: .identified(),
            voteService: voteService
        )

        vm.requestVote()

        XCTAssertTrue(vm.showVoteConfirmation)
        XCTAssertEqual(voteService.upvoteCallCount, 0, "API should not be called before confirmation")
    }

    func test_confirmPendingVote_firesVote() async {
        let voteService = MockVoteService()
        let vm = makeVM(
            config: .fixture(enableOptimisticUpdates: false, confirmVoting: true),
            userService: .identified(),
            voteService: voteService
        )

        vm.requestVote()
        XCTAssertTrue(vm.showVoteConfirmation)

        await vm.confirmPendingVote()

        XCTAssertFalse(vm.showVoteConfirmation)
        XCTAssertEqual(voteService.upvoteCallCount, 1)
    }

    func test_cancelPendingVote_doesNotFire() {
        let voteService = MockVoteService()
        let vm = makeVM(
            config: .fixture(confirmVoting: true),
            userService: .identified(),
            voteService: voteService
        )

        vm.requestVote()
        vm.cancelPendingVote()

        XCTAssertFalse(vm.showVoteConfirmation)
        XCTAssertEqual(voteService.upvoteCallCount, 0)
    }

    // MARK: - Optimistic Updates

    func test_toggleVote_optimisticUpdate_appliedImmediately() async {
        let feature = Feature.fixture(totalVotes: 5, hasVoted: false)
        let vm = makeVM(
            feature: feature,
            config: .fixture(enableOptimisticUpdates: true, confirmVoting: false),
            userService: .identified()
        )

        // The optimistic update runs at the start of the Task body, before the API awaits.
        // Yield to let the spawned Task start executing.
        vm.requestVote()
        await Task.yield()

        XCTAssertTrue(vm.feature.hasVoted, "Optimistic update should flip hasVoted")
        XCTAssertEqual(vm.feature.totalVotes, 6, "Optimistic update should increment totalVotes")
    }

    func test_toggleVote_noOptimisticUpdate_waitForAPI() async {
        let feature = Feature.fixture(totalVotes: 5, hasVoted: false)
        let vm = makeVM(
            feature: feature,
            config: .fixture(enableOptimisticUpdates: false, confirmVoting: false),
            userService: .identified()
        )

        vm.requestVote()

        // Immediately after — should NOT be changed
        XCTAssertFalse(vm.feature.hasVoted, "Without optimistic updates, should not change immediately")
        XCTAssertEqual(vm.feature.totalVotes, 5)

        try? await Task.sleep(nanoseconds: 50_000_000)

        // After API resolves — should be updated
        XCTAssertTrue(vm.feature.hasVoted)
        XCTAssertEqual(vm.feature.totalVotes, 6)
    }

    func test_toggleVote_revertsOnAPIError() async {
        let voteService = MockVoteService()
        voteService.upvoteResult = .failure(TestError.network)

        let feature = Feature.fixture(totalVotes: 5, hasVoted: false)
        let vm = FeatureDetailViewModel(
            feature: feature,
            slug: "test",
            voteService: voteService,
            commentService: MockCommentService(),
            subscriptionService: MockSubscriptionService(),
            userService: .identified(),
            configuration: .fixture(enableOptimisticUpdates: true, confirmVoting: false)
        )

        vm.requestVote()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(vm.feature.hasVoted, "hasVoted should revert after API failure")
        XCTAssertEqual(vm.feature.totalVotes, 5, "totalVotes should revert after API failure")
    }

    // MARK: - Subscription Confirmation

    func test_requestSubscriptionToggle_confirmUnsubscribeShownOnUnsubscribe() {
        let feature = Feature.fixture(hasSubscribed: true)
        let vm = makeVM(
            feature: feature,
            config: .fixture(confirmUnsubscribe: true),
            userService: .identified()
        )

        vm.requestSubscriptionToggle()

        XCTAssertTrue(vm.showUnsubscribeConfirmation, "Should show unsubscribe confirmation")
    }

    func test_requestSubscriptionToggle_noConfirmOnSubscribe() async {
        let subscriptionService = MockSubscriptionService()
        let feature = Feature.fixture(hasSubscribed: false)
        let vm = FeatureDetailViewModel(
            feature: feature,
            slug: "test",
            voteService: MockVoteService(),
            commentService: MockCommentService(),
            subscriptionService: subscriptionService,
            userService: .identified(),
            configuration: .fixture(confirmUnsubscribe: true)
        )

        vm.requestSubscriptionToggle()
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(vm.showUnsubscribeConfirmation, "No confirmation needed when subscribing")
        XCTAssertEqual(subscriptionService.subscribeCallCount, 1, "Subscribe should fire immediately")
    }

    func test_requestSubscriptionToggle_noConfirmWhenDisabled() async {
        let subscriptionService = MockSubscriptionService()
        let feature = Feature.fixture(hasSubscribed: true)
        let vm = FeatureDetailViewModel(
            feature: feature,
            slug: "test",
            voteService: MockVoteService(),
            commentService: MockCommentService(),
            subscriptionService: subscriptionService,
            userService: .identified(email: "user@test.com"),
            configuration: .fixture(confirmUnsubscribe: false)
        )

        vm.requestSubscriptionToggle()
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(vm.showUnsubscribeConfirmation, "No confirmation shown when confirmUnsubscribe=false")
        XCTAssertEqual(subscriptionService.unsubscribeCallCount, 1, "Unsubscribe should fire immediately")
    }

    func test_confirmUnsubscribe_firesUnsubscription() async {
        let subscriptionService = MockSubscriptionService()
        let feature = Feature.fixture(hasSubscribed: true)
        let vm = FeatureDetailViewModel(
            feature: feature,
            slug: "test",
            voteService: MockVoteService(),
            commentService: MockCommentService(),
            subscriptionService: subscriptionService,
            userService: .identified(email: "user@test.com"),
            configuration: .fixture(confirmUnsubscribe: true)
        )

        vm.requestSubscriptionToggle()
        XCTAssertTrue(vm.showUnsubscribeConfirmation)

        await vm.confirmUnsubscribe()

        XCTAssertFalse(vm.showUnsubscribeConfirmation)
        XCTAssertEqual(subscriptionService.unsubscribeCallCount, 1)
    }

    func test_cancelUnsubscribe_doesNotFire() {
        let subscriptionService = MockSubscriptionService()
        let feature = Feature.fixture(hasSubscribed: true)
        let vm = makeVM(
            feature: feature,
            config: .fixture(confirmUnsubscribe: true),
            userService: .identified(),
            subscriptionService: subscriptionService
        )

        vm.requestSubscriptionToggle()
        vm.cancelUnsubscribe()

        XCTAssertFalse(vm.showUnsubscribeConfirmation)
        XCTAssertEqual(subscriptionService.unsubscribeCallCount, 0)
    }

    // MARK: - Custom Anon Blocked Message

    func test_permissionError_usesCustomMessageFromProject() {
        let customMessage = "You must sign in to vote on this board."
        let vm = makeVM(
            config: .fixture(allowAnonymousVoting: false),
            userService: .anonymous(),
            projectCustomization: .fixture(disabledAnonMessage: customMessage)
        )

        vm.requestVote()

        XCTAssertEqual(vm.permissionError, customMessage)
    }
}
