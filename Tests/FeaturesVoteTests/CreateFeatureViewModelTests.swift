import XCTest
@testable import FeaturesVote

@MainActor
final class CreateFeatureViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        config: Configuration = .fixture(),
        userService: UserService = .identified(),
        projectCustomization: Customization? = nil,
        featureService: MockFeatureService = MockFeatureService()
    ) -> CreateFeatureViewModel {
        CreateFeatureViewModel(
            slug: "test",
            availableTags: [],
            featureService: featureService,
            userService: userService,
            configuration: config,
            projectCustomization: projectCustomization
        )
    }

    // MARK: - isValid (requireEmailForCreate)

    func test_isValid_falseWhenEmailRequiredAndMissing() {
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: true),
            userService: .anonymous() // no email
        )
        vm.title = "My Feature"
        vm.description = "A description"

        XCTAssertFalse(vm.isValid, "Form should be invalid when email required but missing")
    }

    func test_isValid_trueWhenEmailRequiredAndPresent() {
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: true),
            userService: .identified(email: "user@example.com")
        )
        vm.title = "My Feature"
        vm.description = "A description"

        XCTAssertTrue(vm.isValid, "Form should be valid when email required and provided")
    }

    func test_isValid_trueWhenEmailNotRequired() {
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: false),
            userService: .anonymous() // no email, but not required
        )
        vm.title = "My Feature"
        vm.description = "A description"

        XCTAssertTrue(vm.isValid, "Form should be valid when email not required")
    }

    func test_isValid_falseWhenTitleEmpty() {
        let vm = makeVM()
        vm.title = ""
        vm.description = "A description"

        XCTAssertFalse(vm.isValid)
    }

    func test_isValid_falseWhenDescriptionEmpty() {
        let vm = makeVM()
        vm.title = "My Feature"
        vm.description = ""

        XCTAssertFalse(vm.isValid)
    }

    func test_isValid_falseWhenBothEmpty() {
        let vm = makeVM()
        XCTAssertFalse(vm.isValid)
    }

    // MARK: - emailRequired computed property

    func test_emailRequired_trueWhenRequiredAndMissing() {
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: true),
            userService: .anonymous()
        )
        XCTAssertTrue(vm.emailRequired)
    }

    func test_emailRequired_falseWhenRequiredAndPresent() {
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: true),
            userService: .identified(email: "user@test.com")
        )
        XCTAssertFalse(vm.emailRequired)
    }

    func test_emailRequired_falseWhenNotRequired() {
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: false),
            userService: .anonymous()
        )
        XCTAssertFalse(vm.emailRequired)
    }

    // MARK: - submit blocked when email required

    func test_submit_blockedWhenEmailRequiredAndMissing() async {
        let featureService = MockFeatureService()
        let vm = makeVM(
            config: .fixture(requireEmailForCreate: true),
            userService: .anonymous(),
            featureService: featureService
        )
        vm.title = "My Feature"
        vm.description = "A description"

        let result = await vm.submit()

        XCTAssertFalse(result, "Submit should fail when email required but missing")
        XCTAssertEqual(featureService.createFeatureCallCount, 0, "API should not be called")
        XCTAssertNotNil(vm.error, "Error should be set")
    }

    func test_submit_succeedsWhenValid() async {
        let featureService = MockFeatureService()
        featureService.createFeatureResult = .success("created-id")

        let vm = makeVM(
            config: .fixture(requireEmailForCreate: false),
            userService: .anonymous(),
            featureService: featureService
        )
        vm.title = "My Feature"
        vm.description = "A description"

        let result = await vm.submit()

        XCTAssertTrue(result, "Submit should succeed with valid form")
        XCTAssertEqual(featureService.createFeatureCallCount, 1, "API should be called")
        XCTAssertNil(vm.error)
    }

    func test_submit_setsTitleAndDescriptionTrimmed() async {
        let featureService = MockFeatureService()
        featureService.createFeatureResult = .success("created-id")

        let vm = makeVM(featureService: featureService)
        vm.title = "  My Feature  "
        vm.description = "  A description  "

        _ = await vm.submit()

        XCTAssertEqual(featureService.lastCreateFeatureTitle, "My Feature")
        XCTAssertEqual(featureService.lastCreateFeatureDescription, "A description")
    }

    // MARK: - Project Customization

    func test_customHeaderText_returnsProjectValue() {
        let vm = makeVM(
            projectCustomization: .fixture(suggestPopupHeaderText: "Request a Feature")
        )
        XCTAssertEqual(vm.customHeaderText, "Request a Feature")
    }

    func test_customHeaderText_returnsNilWhenNotSet() {
        let vm = makeVM(projectCustomization: nil)
        XCTAssertNil(vm.customHeaderText)
    }

    func test_customSuccessMessage_returnsProjectValue() {
        let vm = makeVM(
            projectCustomization: .fixture(suggestPopupSuccessMsg: "Thanks for the suggestion!")
        )
        XCTAssertEqual(vm.customSuccessMessage, "Thanks for the suggestion!")
    }

    func test_customSuccessMessage_returnsNilWhenNotSet() {
        let vm = makeVM(projectCustomization: nil)
        XCTAssertNil(vm.customSuccessMessage)
    }

    // MARK: - Submit failure handling

    func test_submit_setsErrorOnAPIFailure() async {
        let featureService = MockFeatureService()
        featureService.createFeatureResult = .failure(TestError.server)

        let vm = makeVM(featureService: featureService)
        vm.title = "My Feature"
        vm.description = "A description"

        let result = await vm.submit()

        XCTAssertFalse(result)
        XCTAssertNotNil(vm.error)
    }

    // MARK: - reset

    func test_reset_clearsForm() {
        let vm = makeVM()
        vm.title = "Test"
        vm.description = "Desc"
        vm.selectedTags = ["bug"]

        vm.reset()

        XCTAssertTrue(vm.title.isEmpty)
        XCTAssertTrue(vm.description.isEmpty)
        XCTAssertTrue(vm.selectedTags.isEmpty)
    }
}
