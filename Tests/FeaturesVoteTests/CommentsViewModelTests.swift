import XCTest
@testable import FeaturesVote

@MainActor
final class CommentsViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        config: Configuration = .fixture(),
        userService: UserService = .anonymous(),
        projectCustomization: Customization? = nil,
        commentService: MockCommentService = MockCommentService()
    ) -> CommentsViewModel {
        CommentsViewModel(
            featureId: "feature-1",
            slug: "test",
            commentService: commentService,
            userService: userService,
            configuration: config,
            projectCustomization: projectCustomization
        )
    }

    // MARK: - Anonymous Comment Blocking

    func test_isAnonymousCommentingBlocked_trueWhenLocallyDisabled() {
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: false),
            userService: .anonymous()
        )

        XCTAssertTrue(vm.isAnonymousCommentingBlocked)
    }

    func test_isAnonymousCommentingBlocked_trueWhenServerDisabled() {
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: true), // local allows
            userService: .anonymous(),
            projectCustomization: .fixture(isAnonDisabled: true) // server blocks
        )

        XCTAssertTrue(vm.isAnonymousCommentingBlocked)
    }

    func test_isAnonymousCommentingBlocked_falseWhenIdentifiedUser() {
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: false),
            userService: .identified()
        )

        XCTAssertFalse(vm.isAnonymousCommentingBlocked, "Identified user should not be blocked")
    }

    func test_isAnonymousCommentingBlocked_falseWhenBothAllow() {
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: true),
            userService: .anonymous(),
            projectCustomization: .fixture(isAnonDisabled: nil)
        )

        XCTAssertFalse(vm.isAnonymousCommentingBlocked)
    }

    // MARK: - submitComment blocked

    func test_submitComment_blockedWhenAnonCommentsDisabled() async {
        let commentService = MockCommentService()
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: false),
            userService: .anonymous(),
            commentService: commentService
        )
        vm.commentText = "Hello!"

        let result = await vm.submitComment()

        XCTAssertFalse(result, "Submit should fail when anon commenting is blocked")
        XCTAssertNotNil(vm.permissionError, "Permission error should be set")
        XCTAssertEqual(commentService.addCommentCallCount, 0, "API should not be called")
    }

    func test_submitComment_blockedByProjectIsAnonDisabled() async {
        let commentService = MockCommentService()
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: true), // local allows
            userService: .anonymous(),
            projectCustomization: .fixture(isAnonDisabled: true),
            commentService: commentService
        )
        vm.commentText = "Hello!"

        let result = await vm.submitComment()

        XCTAssertFalse(result, "Submit should fail when server blocks anon")
        XCTAssertNotNil(vm.permissionError)
        XCTAssertEqual(commentService.addCommentCallCount, 0)
    }

    func test_submitComment_allowedWhenAnonCommentsEnabled() async {
        let commentService = MockCommentService()
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: true),
            userService: .anonymous(),
            commentService: commentService
        )
        vm.commentText = "Hello from anon!"

        let result = await vm.submitComment()

        XCTAssertTrue(result, "Submit should succeed when anon commenting is allowed")
        XCTAssertNil(vm.permissionError)
        XCTAssertEqual(commentService.addCommentCallCount, 1)
    }

    func test_submitComment_allowedWhenIdentifiedUser() async {
        let commentService = MockCommentService()
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: false),
            userService: .identified(),
            commentService: commentService
        )
        vm.commentText = "Hello from identified user!"

        let result = await vm.submitComment()

        XCTAssertTrue(result, "Identified user should always be able to comment")
        XCTAssertNil(vm.permissionError)
        XCTAssertEqual(commentService.addCommentCallCount, 1)
    }

    // MARK: - submitComment validation

    func test_submitComment_failsWhenEmpty() async {
        let commentService = MockCommentService()
        let vm = makeVM(userService: .identified(), commentService: commentService)
        vm.commentText = ""

        let result = await vm.submitComment()

        XCTAssertFalse(result)
        XCTAssertEqual(commentService.addCommentCallCount, 0)
    }

    func test_submitComment_failsWhenWhitespaceOnly() async {
        let commentService = MockCommentService()
        let vm = makeVM(userService: .identified(), commentService: commentService)
        vm.commentText = "   \n   "

        let result = await vm.submitComment()

        XCTAssertFalse(result)
        XCTAssertEqual(commentService.addCommentCallCount, 0)
    }

    // MARK: - Custom blocked message

    func test_anonBlockedMessage_usesProjectCustomization() {
        let customMessage = "Sign in with your account to comment."
        let vm = makeVM(
            projectCustomization: .fixture(disabledAnonMessage: customMessage)
        )

        XCTAssertEqual(vm.anonBlockedMessage, customMessage)
    }

    func test_anonBlockedMessage_defaultFallback() {
        let vm = makeVM(projectCustomization: nil)
        XCTAssertFalse(vm.anonBlockedMessage.isEmpty, "Default message should not be empty")
    }

    // MARK: - clearPermissionError

    func test_clearPermissionError_nilsError() async {
        let commentService = MockCommentService()
        let vm = makeVM(
            config: .fixture(allowAnonymousComments: false),
            userService: .anonymous(),
            commentService: commentService
        )
        vm.commentText = "Hello!"
        _ = await vm.submitComment()
        XCTAssertNotNil(vm.permissionError)

        vm.clearPermissionError()

        XCTAssertNil(vm.permissionError)
    }
}
