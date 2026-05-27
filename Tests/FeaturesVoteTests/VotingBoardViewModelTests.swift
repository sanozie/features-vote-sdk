import XCTest
@testable import FeaturesVote

@MainActor
final class VotingBoardViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        features: [Feature] = [],
        config: Configuration = .fixture(),
        userService: UserService = .anonymous()
    ) -> VotingBoardViewModel {
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success(features)
        return VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: MockVoteService(),
            userService: userService,
            configuration: config
        )
    }

    // MARK: - Anonymous Voting

    func test_requestVote_blockedWhenAnonVotingDisabled() async {
        let feature = Feature.fixture()
        let vm = makeVM(
            features: [feature],
            config: .fixture(allowAnonymousVoting: false),
            userService: .anonymous()
        )
        await vm.loadFeatures()

        vm.requestVote(for: feature)

        XCTAssertNotNil(vm.permissionError, "Expected permission error to be set")
        XCTAssertTrue(vm.showPermissionAlert, "Expected permission alert to show")
        XCTAssertFalse(vm.showVoteConfirmation, "Vote confirmation should NOT appear when permission blocked")
    }

    func test_requestVote_allowedWhenAnonVotingEnabled() async {
        let voteService = MockVoteService()
        let featureService = MockFeatureService()
        let feature = Feature.fixture()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .anonymous(),
            configuration: .fixture(allowAnonymousVoting: true, confirmVoting: false)
        )
        await vm.loadFeatures()

        vm.requestVote(for: feature)

        // Give the async task time to execute
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNil(vm.permissionError, "No permission error expected")
        XCTAssertFalse(vm.showPermissionAlert, "No permission alert expected")
        XCTAssertEqual(voteService.upvoteCallCount, 1, "Upvote should have been called")
    }

    func test_requestVote_blockedByProjectIsAnonDisabled() async {
        let feature = Feature.fixture()
        let vm = makeVM(
            features: [feature],
            config: .fixture(allowAnonymousVoting: true), // local config allows it
            userService: .anonymous()
        )
        // Inject server-side block via project customization
        await vm.loadProject()
        // Simulate project with isAnonDisabled = true by directly testing the path:
        // We build a VM whose project says isAnonDisabled = true
        let featureService2 = MockFeatureService()
        featureService2.fetchProjectResult = .success(Project.fixture(isAnonDisabled: true))
        featureService2.fetchFeaturesResult = .success([feature])

        let vm2 = VotingBoardViewModel(
            slug: "test",
            featureService: featureService2,
            voteService: MockVoteService(),
            userService: .anonymous(),
            configuration: .fixture(allowAnonymousVoting: true)
        )
        await vm2.loadProject()
        await vm2.loadFeatures()

        vm2.requestVote(for: feature)

        XCTAssertNotNil(vm2.permissionError, "Server isAnonDisabled should block anonymous vote")
        XCTAssertTrue(vm2.showPermissionAlert)
    }

    // MARK: - Optimistic Updates

    func test_requestVote_optimisticUpdate_appliedImmediately() async {
        let feature = Feature.fixture(totalVotes: 5, hasVoted: false)
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: MockVoteService(),
            userService: .identified(),
            configuration: .fixture(enableOptimisticUpdates: true, confirmVoting: false)
        )
        await vm.loadFeatures()

        XCTAssertFalse(vm.features[0].hasVoted)
        XCTAssertEqual(vm.features[0].totalVotes, 5)

        // Fire vote — the optimistic update runs at the start of the Task body,
        // before the API awaits. Yield to let the spawned Task start.
        vm.requestVote(for: feature)
        await Task.yield()

        XCTAssertTrue(vm.features[0].hasVoted, "Optimistic update should flip hasVoted")
        XCTAssertEqual(vm.features[0].totalVotes, 6, "Optimistic update should increment totalVotes")
    }

    func test_requestVote_noOptimisticUpdate_waitForAPI() async {
        let voteService = MockVoteService()
        let feature = Feature.fixture(totalVotes: 5, hasVoted: false)
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let config = Configuration.fixture(enableOptimisticUpdates: false, confirmVoting: false)

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .identified(),
            configuration: config
        )
        await vm.loadFeatures()

        XCTAssertFalse(vm.features[0].hasVoted)
        XCTAssertEqual(vm.features[0].totalVotes, 5)

        // With no optimistic updates, feature should NOT change immediately
        vm.requestVote(for: feature)

        // Immediately after call (synchronous check), vote should NOT be applied yet
        XCTAssertFalse(vm.features[0].hasVoted, "Without optimistic updates, hasVoted should not flip immediately")
        XCTAssertEqual(vm.features[0].totalVotes, 5, "Without optimistic updates, totalVotes should not change immediately")

        // Wait for async to complete
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Now it should be applied
        XCTAssertTrue(vm.features[0].hasVoted, "After API success, hasVoted should flip")
        XCTAssertEqual(vm.features[0].totalVotes, 6, "After API success, totalVotes should increment")
    }

    // MARK: - Vote Confirmation

    func test_requestVote_confirmationRequired_showsDialog() async {
        let voteService = MockVoteService()
        let feature = Feature.fixture()
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .identified(),
            configuration: .fixture(confirmVoting: true)
        )
        await vm.loadFeatures()

        vm.requestVote(for: feature)

        XCTAssertTrue(vm.showVoteConfirmation, "Confirmation dialog should appear")
        XCTAssertEqual(voteService.upvoteCallCount, 0, "API should NOT be called before confirmation")
    }

    func test_requestVote_noConfirmation_firesImmediately() async {
        let voteService = MockVoteService()
        let feature = Feature.fixture()
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .identified(),
            configuration: .fixture(confirmVoting: false)
        )
        await vm.loadFeatures()

        vm.requestVote(for: feature)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(vm.showVoteConfirmation, "No confirmation dialog should appear")
        XCTAssertEqual(voteService.upvoteCallCount, 1, "API should be called immediately")
    }

    func test_confirmPendingVote_firesVoteAfterConfirmation() async {
        let voteService = MockVoteService()
        let feature = Feature.fixture()
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .identified(),
            configuration: .fixture(enableOptimisticUpdates: false, confirmVoting: true)
        )
        await vm.loadFeatures()

        // Request vote — dialog appears
        vm.requestVote(for: feature)
        XCTAssertTrue(vm.showVoteConfirmation)
        XCTAssertEqual(voteService.upvoteCallCount, 0)

        // Confirm
        await vm.confirmPendingVote()

        XCTAssertFalse(vm.showVoteConfirmation, "Dialog should be dismissed after confirmation")
        XCTAssertEqual(voteService.upvoteCallCount, 1, "Vote API should be called after confirmation")
    }

    func test_cancelPendingVote_doesNotFire() async {
        let voteService = MockVoteService()
        let feature = Feature.fixture()
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .identified(),
            configuration: .fixture(confirmVoting: true)
        )
        await vm.loadFeatures()

        vm.requestVote(for: feature)
        XCTAssertTrue(vm.showVoteConfirmation)

        vm.cancelPendingVote()

        XCTAssertFalse(vm.showVoteConfirmation, "Dialog should be dismissed")
        XCTAssertEqual(voteService.upvoteCallCount, 0, "Vote API should NOT be called")
    }

    // MARK: - Watermark

    func test_shouldShowWatermark_respectsLocalConfig_whenTrue() {
        let vm = makeVM(config: .fixture(showWatermark: true))
        XCTAssertTrue(vm.shouldShowWatermark)
    }

    func test_shouldShowWatermark_respectsLocalConfig_whenFalse() {
        let vm = makeVM(config: .fixture(showWatermark: false))
        XCTAssertFalse(vm.shouldShowWatermark)
    }

    func test_shouldShowWatermark_hiddenByServerOverride() async {
        let featureService = MockFeatureService()
        featureService.fetchProjectResult = .success(Project.fixture(hideWatermark: true))

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: MockVoteService(),
            userService: .anonymous(),
            configuration: .fixture(showWatermark: true) // local says show
        )
        await vm.loadProject()

        XCTAssertFalse(vm.shouldShowWatermark, "Server hideWatermark=true should override local config")
    }

    // MARK: - isInProgressOnTop

    func test_filteredFeatures_inProgressOnTopDefault() async {
        let pending = Feature.fixture(id: "a", totalVotes: 100, status: .pending)
        let inProgress = Feature.fixture(id: "b", totalVotes: 1, status: .inProgress)
        let approved = Feature.fixture(id: "c", totalVotes: 50, status: .approved)

        let featureService = MockFeatureService()
        featureService.fetchProjectResult = .success(Project.fixture(isInProgressOnTop: true))
        featureService.fetchFeaturesResult = .success([pending, approved, inProgress])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: MockVoteService(),
            userService: .anonymous(),
            configuration: .default
        )
        await vm.loadProject()
        await vm.loadFeatures()

        let filtered = vm.filteredFeatures
        // In-progress should be first despite lowest votes
        XCTAssertEqual(filtered.first?.id, "b", "inProgress should be pinned to top")
    }

    func test_filteredFeatures_inProgressNotPinnedWhenDisabled() async {
        let pending = Feature.fixture(id: "a", totalVotes: 100, status: .pending)
        let inProgress = Feature.fixture(id: "b", totalVotes: 1, status: .inProgress)

        let featureService = MockFeatureService()
        featureService.fetchProjectResult = .success(Project.fixture(isInProgressOnTop: false))
        featureService.fetchFeaturesResult = .success([inProgress, pending])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: MockVoteService(),
            userService: .anonymous(),
            configuration: .default
        )
        await vm.loadProject()
        await vm.loadFeatures()

        let filtered = vm.filteredFeatures
        // Pending has more votes and isInProgressOnTop=false, so pending should come first
        XCTAssertEqual(filtered.first?.id, "a", "Highest votes should be first when pinning is disabled")
    }

    // MARK: - Optimistic Revert on Error

    func test_toggleVote_revertsOnAPIError() async {
        let voteService = MockVoteService()
        voteService.upvoteResult = .failure(TestError.network)

        let feature = Feature.fixture(totalVotes: 5, hasVoted: false)
        let featureService = MockFeatureService()
        featureService.fetchFeaturesResult = .success([feature])

        let vm = VotingBoardViewModel(
            slug: "test",
            featureService: featureService,
            voteService: voteService,
            userService: .identified(),
            configuration: .fixture(enableOptimisticUpdates: true, confirmVoting: false)
        )
        await vm.loadFeatures()

        vm.requestVote(for: feature)
        // Wait for async to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should revert to original state
        XCTAssertFalse(vm.features[0].hasVoted, "hasVoted should revert after API failure")
        XCTAssertEqual(vm.features[0].totalVotes, 5, "totalVotes should revert after API failure")
    }
}
