import Foundation

/// Localization strings for Features.Vote widgets
public struct Localization {
    // MARK: - Voting Board

    /// Title for the voting board view
    public var votingBoardTitle: String

    /// Label for the "Open" tab
    public var openTab: String

    /// Label for the "Done" tab
    public var doneTab: String

    /// Sort option: by votes
    public var sortByVotes: String

    /// Sort option: by recent
    public var sortByRecent: String

    /// Message shown when no features exist
    public var noFeaturesMessage: String

    /// Label for votes count (plural)
    public var votes: String

    /// Label for single vote
    public var vote: String
    
    /// Placeholder for search field
    public var searchPlaceholder: String
    
    /// Label for create feature button on board
    public var createFeatureButton: String

    // MARK: - Feature Detail

    /// Label for comments count (plural)
    public var comments: String

    /// Section header for comments
    public var Comments: String

    /// Label for single comment
    public var comment: String

    /// Button label: Subscribe
    public var subscribe: String

    /// Button label: Subscribed (active state)
    public var subscribed: String

    /// Button label: Share
    public var share: String

    /// Status label: Pending
    public var pending: String

    /// Status label: Approved
    public var approved: String

    /// Status label: In Progress
    public var inProgress: String

    /// Status label: Done
    public var done: String

    /// Status label: Rejected
    public var rejected: String

    // MARK: - Create Feature

    /// Title for create feature view
    public var createFeatureTitle: String

    /// Placeholder for title field
    public var titlePlaceholder: String

    /// Placeholder for description field
    public var descriptionPlaceholder: String

    /// Label for tag selector
    public var selectTags: String

    /// Label for image attachment button
    public var attachImage: String

    /// Button label: Submit
    public var submit: String

    /// Button label: Cancel
    public var cancel: String

    /// Success message after creating feature
    public var successMessage: String

    // MARK: - Comments

    /// Section header: Add a comment
    public var addComment: String

    /// Placeholder for comment input
    public var commentPlaceholder: String

    /// Button label: Send comment
    public var sendComment: String

    /// Label for admin badge
    public var adminBadge: String

    // MARK: - Errors

    /// Error alert title
    public var errorTitle: String

    /// Retry button label
    public var retryButton: String

    /// Network error message
    public var networkError: String

    /// Generic error message
    public var genericError: String

    // MARK: - Loading

    /// Loading indicator text
    public var loading: String

    // MARK: - Authentication

    /// Prompt for anonymous users
    public var anonymousPrompt: String

    /// Login button label
    public var loginButton: String

    // MARK: - Validation

    /// Error: Title required
    public var titleRequired: String

    /// Error: Description required
    public var descriptionRequired: String

    /// Error: Email invalid
    public var emailInvalid: String

    // MARK: - Initialization

    public init(
        votingBoardTitle: String = "Features & Bugs board",
        openTab: String = "Open",
        doneTab: String = "Done",
        sortByVotes: String = "Most Voted",
        sortByRecent: String = "Most Recent",
        noFeaturesMessage: String = "No feature requests yet",
        votes: String = "votes",
        vote: String = "vote",
        searchPlaceholder: String = "Search posts...",
        createFeatureButton: String = "Create",
        comments: String = "comments",
        Comments: String = "Comments",
        comment: String = "comment",
        subscribe: String = "Subscribe",
        subscribed: String = "Subscribed",
        share: String = "Share",
        pending: String = "Pending",
        approved: String = "Approved",
        inProgress: String = "In Progress",
        done: String = "Done",
        rejected: String = "Rejected",
        createFeatureTitle: String = "Suggest a Feature",
        titlePlaceholder: String = "Feature title",
        descriptionPlaceholder: String = "Describe your feature request...",
        selectTags: String = "Select tags",
        attachImage: String = "Attach image",
        submit: String = "Submit",
        cancel: String = "Cancel",
        successMessage: String = "Feature request submitted!",
        addComment: String = "Add a comment",
        commentPlaceholder: String = "Write a comment...",
        sendComment: String = "Send",
        adminBadge: String = "Admin",
        errorTitle: String = "Error",
        retryButton: String = "Try Again",
        networkError: String = "Connection error. Please check your internet connection.",
        genericError: String = "An error occurred. Please try again.",
        loading: String = "Loading...",
        anonymousPrompt: String = "Sign in to vote and comment",
        loginButton: String = "Sign In",
        titleRequired: String = "Title is required",
        descriptionRequired: String = "Description is required",
        emailInvalid: String = "Invalid email address"
    ) {
        self.votingBoardTitle = votingBoardTitle
        self.openTab = openTab
        self.doneTab = doneTab
        self.sortByVotes = sortByVotes
        self.sortByRecent = sortByRecent
        self.noFeaturesMessage = noFeaturesMessage
        self.votes = votes
        self.vote = vote
        self.searchPlaceholder = searchPlaceholder
        self.createFeatureButton = createFeatureButton
        self.comments = comments
        self.Comments = Comments
        self.comment = comment
        self.subscribe = subscribe
        self.subscribed = subscribed
        self.share = share
        self.pending = pending
        self.approved = approved
        self.inProgress = inProgress
        self.done = done
        self.rejected = rejected
        self.createFeatureTitle = createFeatureTitle
        self.titlePlaceholder = titlePlaceholder
        self.descriptionPlaceholder = descriptionPlaceholder
        self.selectTags = selectTags
        self.attachImage = attachImage
        self.submit = submit
        self.cancel = cancel
        self.successMessage = successMessage
        self.addComment = addComment
        self.commentPlaceholder = commentPlaceholder
        self.sendComment = sendComment
        self.adminBadge = adminBadge
        self.errorTitle = errorTitle
        self.retryButton = retryButton
        self.networkError = networkError
        self.genericError = genericError
        self.loading = loading
        self.anonymousPrompt = anonymousPrompt
        self.loginButton = loginButton
        self.titleRequired = titleRequired
        self.descriptionRequired = descriptionRequired
        self.emailInvalid = emailInvalid
    }

    /// Default localization (English)
    public static let `default` = Localization()
}
