// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Savy';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get optional => 'Optional';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorNetwork => 'Network error, please try again';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorInvalidAmount => 'Invalid amount';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get langPickerTitle => 'Choose language';

  @override
  String get langFr => 'Français';

  @override
  String get langEn => 'English';

  @override
  String get langAr => 'العربية';

  @override
  String get loginWelcome => 'Welcome 👋';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginEmailHint => 'example@email.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Your password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignupLink => 'Sign up';

  @override
  String get loginOr => 'Or continue with';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginErrorEmpty => 'Please fill in all fields';

  @override
  String get loginErrorInvalidEmail => 'Invalid email';

  @override
  String get loginErrorWrongPassword => 'Wrong password';

  @override
  String get loginErrorUserNotFound => 'No account found with this email';

  @override
  String get loginErrorTooManyRequests =>
      'Too many attempts, please try again later';

  @override
  String get loginErrorEmailNotVerified => 'Email not verified';

  @override
  String get loginVerifyEmailTitle => 'Verify your email';

  @override
  String get loginVerifyEmailMessage => 'A verification email was sent to';

  @override
  String get loginVerifyEmailResend => 'Resend email';

  @override
  String get loginVerifyEmailDone => 'I\'ve verified';

  @override
  String loginVerifyEmailCooldown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get loginResendSuccess => 'Verification email resent!';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address, we\'ll send you a reset link.';

  @override
  String get forgotPasswordEmailLabel => 'Email address';

  @override
  String get forgotPasswordSend => 'Send link';

  @override
  String get forgotPasswordSuccess => 'Reset email sent!';

  @override
  String get forgotPasswordBack => 'Back to login';

  @override
  String get signupTitle => 'Create an account';

  @override
  String get signupSubtitle => 'Join Savy and manage your savings';

  @override
  String get signupNameLabel => 'Full name';

  @override
  String get signupNameHint => 'Your name';

  @override
  String get signupEmailLabel => 'Email address';

  @override
  String get signupEmailHint => 'example@email.com';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordHint => 'Minimum 8 characters';

  @override
  String get signupConfirmPasswordLabel => 'Confirm password';

  @override
  String get signupConfirmPasswordHint => 'Repeat password';

  @override
  String get signupButton => 'Sign up';

  @override
  String get signupAlreadyAccount => 'Already have an account?';

  @override
  String get signupLoginLink => 'Sign in';

  @override
  String get signupAcceptTerms => 'I accept the';

  @override
  String get signupTerms => 'Terms of service';

  @override
  String get signupAnd => 'and the';

  @override
  String get signupPrivacy => 'Privacy policy';

  @override
  String get signupPasswordStrength => 'Password strength:';

  @override
  String get signupPasswordWeak => 'Weak';

  @override
  String get signupPasswordMedium => 'Medium';

  @override
  String get signupPasswordGood => 'Good';

  @override
  String get signupPasswordExcellent => 'Excellent';

  @override
  String get signupErrorName => 'Please enter your name';

  @override
  String get signupErrorEmail => 'Invalid email';

  @override
  String get signupErrorPassword => 'Password too short (min. 8 characters)';

  @override
  String get signupErrorConfirm => 'Passwords do not match';

  @override
  String get signupErrorTerms => 'Please accept the terms';

  @override
  String get signupErrorEmailInUse => 'This email is already in use';

  @override
  String get signupEmailSentTitle => 'Email sent! 📬';

  @override
  String signupEmailSentMessage(String email) {
    return 'A verification email was sent to $email. Check your inbox before signing in.';
  }

  @override
  String get signupEmailSentButton => 'Go to login';

  @override
  String get signupGoogle => 'Continue with Google';

  @override
  String get onboardingNameTitle => 'What\'s your first name?';

  @override
  String get onboardingNameSubtitle =>
      'Welcome to Savy! Let\'s start by getting to know you.';

  @override
  String get onboardingNameHint => 'Enter your first name';

  @override
  String get onboardingNameError => 'Please enter your first name';

  @override
  String get onboardingNameNext => 'Continue';

  @override
  String get onboardingBalanceTitle => 'Your starting balance';

  @override
  String get onboardingBalanceSubtitle =>
      'What is your current balance? You can change it later.';

  @override
  String get onboardingBalanceHint => '0.00';

  @override
  String get onboardingBalanceCurrency => 'Currency';

  @override
  String get onboardingBalanceFinish => 'Get started';

  @override
  String get onboardingBalanceError => 'Please enter a valid amount';

  @override
  String get homeHello => 'Hello,';

  @override
  String get homeSubtitle => 'Here is your dashboard';

  @override
  String get homeTotalBalance => 'Total balance';

  @override
  String get homeBudgetUsed => 'of your budget used';

  @override
  String get homeHealthScore => 'Health score';

  @override
  String get homeIncome => 'Income';

  @override
  String get homeExpenses => 'Expenses';

  @override
  String get homeMyObjectives => 'My objectives';

  @override
  String get homeRecentTransactions => 'Recent transactions';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeNoObjectives => 'No objectives created';

  @override
  String get homeNoObjectivesHint => 'Create your first savings objective';

  @override
  String get homeNoTransactions => 'No transactions';

  @override
  String get homeScoreExcellent => 'Excellent';

  @override
  String get homeScoreGood => 'Good';

  @override
  String get homeScoreAverage => 'Average';

  @override
  String get homeScorePoor => 'Needs improvement';

  @override
  String homeObjectiveProgress(String percent) {
    return '$percent% reached';
  }

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetSubtitle => 'Manage your expenses';

  @override
  String get budgetTabBudget => 'Budget';

  @override
  String get budgetTabRevenues => 'Income';

  @override
  String get budgetTotal => 'Total budget';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetAddCategory => 'Add category';

  @override
  String get budgetAddRevenue => 'Add income';

  @override
  String get budgetNoCategoryTitle => 'No categories';

  @override
  String get budgetNoCategoryHint => 'Tap + to add your first budget';

  @override
  String get budgetNoRevenueTitle => 'No income';

  @override
  String get budgetNoRevenueHint => 'Tap + to add your first income';

  @override
  String get budgetDeleteCategory => 'Delete category';

  @override
  String get budgetDeleteRevenue => 'Delete income';

  @override
  String get budgetDeleteConfirm => 'Are you sure you want to delete';

  @override
  String get budgetDeleteSuccess => 'Deleted successfully';

  @override
  String get budgetCategoryBudget => 'Budget';

  @override
  String get budgetCategorySpent => 'Spent';

  @override
  String get budgetCategoryRemaining => 'Remaining';

  @override
  String get budgetAddTransaction => 'Add expense';

  @override
  String get budgetTransactionLabel => 'Label';

  @override
  String get budgetTransactionAmount => 'Amount';

  @override
  String get budgetTransactionNote => 'Note';

  @override
  String get budgetTransactionDate => 'Date';

  @override
  String get budgetTransactionAdd => 'Add expense';

  @override
  String get budgetRevenueSource => 'Source';

  @override
  String get budgetRevenueAmount => 'Amount';

  @override
  String get budgetRevenueType => 'Type';

  @override
  String get budgetRevenueAdd => 'Add income';

  @override
  String get budgetNewCategory => 'New category';

  @override
  String get budgetCategoryName => 'Category name';

  @override
  String get budgetCategoryBudgetLabel => 'Budget (monthly)';

  @override
  String get budgetCategoryCreate => 'Create';

  @override
  String get budgetCategoryIcon => 'Icon';

  @override
  String get budgetCategoryColor => 'Color';

  @override
  String get budgetOverspent => 'Over budget';

  @override
  String budgetPercent(String percent) {
    return '$percent%';
  }

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catLeisure => 'Leisure';

  @override
  String get catAcademic => 'Academic';

  @override
  String get catHealth => 'Health';

  @override
  String get catOther => 'Other';

  @override
  String get objectivesTitle => 'Objectives';

  @override
  String get objectivesSubtitle => 'Your savings goals';

  @override
  String get objectivesTotalSavings => 'Total savings';

  @override
  String get objectivesAdd => 'New objective';

  @override
  String get objectivesEmpty => 'No objectives yet';

  @override
  String get objectivesEmptyHint => 'Tap + to create one';

  @override
  String objectivesCount(int count) {
    return '$count objective';
  }

  @override
  String objectivesCountPlural(int count) {
    return '$count objectives';
  }

  @override
  String get objectivesDeleteTitle => 'Delete objective';

  @override
  String objectivesDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get objectivesAmountToAdd => 'Amount to add';

  @override
  String get objectivesFeedTitle => 'Fund';

  @override
  String get objectivesConfirmPayment => 'Confirm payment';

  @override
  String get objectivesMissing => 'Missing:';

  @override
  String get objectivesReached => '% reached';

  @override
  String get objectivesCompleted => 'Objective reached! 🎉';

  @override
  String objectivesAddedSuccess(String amount, String name) {
    return '+ $amount added to \"$name\"';
  }

  @override
  String get objectivesName => 'Objective name';

  @override
  String get objectivesNameHint => 'e.g. Car, Trip...';

  @override
  String get objectivesTarget => 'Target amount';

  @override
  String get objectivesSaved => 'Already saved';

  @override
  String get objectivesDeadline => 'Deadline';

  @override
  String get objectivesPriority => 'Priority';

  @override
  String get objectivesColor => 'Color';

  @override
  String get objectivesIcon => 'Icon';

  @override
  String get objectivesCreate => 'Create objective';

  @override
  String get objectivesSortTitle => 'Sort objectives';

  @override
  String get objectivesSortSubtitle => 'Choose display order';

  @override
  String get objectivesSortByDate => 'By date';

  @override
  String get objectivesSortDateDesc => 'Newest → oldest';

  @override
  String get objectivesSortDateAsc => 'Oldest → newest';

  @override
  String get objectivesSortDateDescSub => 'Most recent first';

  @override
  String get objectivesSortDateAscSub => 'Oldest first';

  @override
  String get objectivesSortByPriority => 'By priority';

  @override
  String get objectivesSortPriorityHighFirst => 'Priority: high → low';

  @override
  String get objectivesSortPriorityLowFirst => 'Priority: low → high';

  @override
  String get objectivesSortPriorityHighFirstSub => 'Most important first';

  @override
  String get objectivesSortPriorityLowFirstSub => 'Least important first';

  @override
  String get objectivesSortByProgress => 'By progress';

  @override
  String get objectivesSortProgressDesc => 'Progress: most reached';

  @override
  String get objectivesSortProgressAsc => 'Progress: least reached';

  @override
  String get objectivesSortProgressDescSub => 'Closest to goal first';

  @override
  String get objectivesSortProgressAscSub => 'Least advanced first';

  @override
  String objectivesSuggestion(String amount) {
    return 'Save $amount/month to reach your goal on time.';
  }

  @override
  String get objectivesDeadlineLabel => 'Deadline:';

  @override
  String get objectivesPriorityLabel => 'Priority';

  @override
  String get objectivesAmountError => 'Please enter an amount';

  @override
  String get objectivesAmountInvalid => 'Invalid amount';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsSubtitle => 'Complete history';

  @override
  String get transactionsSearch => 'Search a transaction...';

  @override
  String get transactionsAll => 'All';

  @override
  String get transactionsExpenses => 'Expenses';

  @override
  String get transactionsRevenues => 'Income';

  @override
  String get transactionsEmpty => 'No transactions found';

  @override
  String transactionsCount(int count) {
    return '$count transaction(s)';
  }

  @override
  String get transactionsDeleteTitle => 'Delete transaction';

  @override
  String get transactionsDeleteConfirm => 'Are you sure you want to delete';

  @override
  String get transactionsDeleteSuccess => 'Transaction deleted';

  @override
  String get transactionsRevenueBadge => 'Income';

  @override
  String get transactionsRevenueHint =>
      'Delete this income from the Income page.';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileObjectivesStat => 'objectives';

  @override
  String get profileTransactionsStat => 'transactions';

  @override
  String get profileHealthScore => 'Health score';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileCurrency => 'Currency';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileHelp => 'Help & Support';

  @override
  String get profileBackup => 'Backup';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLogoutTitle => 'Sign out';

  @override
  String get profileLogoutMessage => 'Do you want to sign out?';

  @override
  String get profileSelectCurrency => 'Choose currency';

  @override
  String get profileSearchCurrency => 'Search currency...';

  @override
  String get profileSelectLanguage => 'Choose language';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profilePhotoGallery => 'Gallery';

  @override
  String get profilePhotoCamera => 'Camera';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileName => 'Full name';

  @override
  String get editProfileNameHint => 'Your name';

  @override
  String get editProfileGender => 'Gender';

  @override
  String get editProfileBirthdate => 'Date of birth';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileSuccess => 'Profile updated successfully';

  @override
  String get editProfileGenderMale => 'Male';

  @override
  String get editProfileGenderFemale => 'Female';

  @override
  String get editProfileGenderOther => 'Other';

  @override
  String get editProfileGenderNotSpecified => 'Not specified';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountReasonTitle => 'Why do you want to leave?';

  @override
  String get deleteAccountReason1 => 'I no longer use the app';

  @override
  String get deleteAccountReason2 => 'The app doesn\'t meet my needs';

  @override
  String get deleteAccountReason3 => 'Privacy concerns';

  @override
  String get deleteAccountReason4 => 'Too complicated to use';

  @override
  String get deleteAccountReason5 => 'Other';

  @override
  String get deleteAccountOtherHint => 'Tell us more...';

  @override
  String get deleteAccountWarning =>
      '⚠️ This action is irreversible. All your data will be permanently deleted.';

  @override
  String get deleteAccountConfirmLabel => 'Type \"delete\" to confirm';

  @override
  String get deleteAccountConfirmHint => 'delete';

  @override
  String get deleteAccountConfirmWord => 'delete';

  @override
  String get deleteAccountButton => 'Delete permanently';

  @override
  String get deleteAccountErrorReason => 'Please choose a reason';

  @override
  String get deleteAccountErrorConfirm => 'Type \"delete\" to confirm';

  @override
  String get deleteAccountErrorReauth =>
      'For security reasons, please sign in again before deleting your account.';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityChangePassword => 'Change password';

  @override
  String get securityTwoFactor => 'Two-factor authentication';

  @override
  String get securityActiveSessions => 'Active sessions';

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpFaq => 'FAQ';

  @override
  String get helpContact => 'Contact us';

  @override
  String get helpVersion => 'Version';

  @override
  String get helpScreenTitle => 'Help & FAQ';

  @override
  String get helpChipAll => 'All';

  @override
  String get helpSearchHint => 'Search help...';

  @override
  String get helpSearchNoResults => 'No results';

  @override
  String get helpSearchTryOther => 'Try other keywords';

  @override
  String get helpContactDialogTitle => 'Contact support';

  @override
  String get helpContactSubject => 'Subject';

  @override
  String get helpContactSubjectHint => 'Ex: Issue with my budget...';

  @override
  String get helpContactMessage => 'Message';

  @override
  String get helpContactMessageHint => 'Describe your issue in detail...';

  @override
  String get helpContactFillAll => 'Please fill all fields';

  @override
  String get helpContactSend => 'Send';

  @override
  String get helpContactSuccessTitle => 'Message sent!';

  @override
  String get helpContactSuccessBody =>
      'Your message has been sent to our team. We will get back to you as soon as possible.';

  @override
  String get helpContactSuccessBtn => 'Perfect!';

  @override
  String get helpVersionDesc => 'Budget management app for students';

  @override
  String get backupTitle => 'Backup & Export';

  @override
  String get backupExportPdf => 'Export as PDF';

  @override
  String get backupExportCsv => 'Export as CSV';

  @override
  String get backupLastBackup => 'Last backup';

  @override
  String get notifBudgetAlert => 'Budget alert';

  @override
  String notifBudgetAlertBody(String percent, String category) {
    return 'You\'ve reached $percent% of your $category budget';
  }

  @override
  String get notifObjectiveComplete => 'Objective reached! 🎉';

  @override
  String notifObjectiveCompleteBody(String name) {
    return 'Congratulations! You\'ve reached your \"$name\" objective.';
  }

  @override
  String get legalTermsTitle => 'Terms of service';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get splashTagline => 'Manage your savings smartly';

  @override
  String get legalScrollHint => 'Scroll to read';

  @override
  String get legalAcceptTerms => 'I accept the terms';

  @override
  String get legalAcceptPrivacy => 'I accept the policy';

  @override
  String get navHome => 'Home';

  @override
  String get navBudget => 'Budget';

  @override
  String get navObjectives => 'Objectives';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navProfile => 'Profile';

  @override
  String get editProfilePhotoTitle => 'Profile photo';

  @override
  String get editProfilePhotoGallery => 'Gallery';

  @override
  String get editProfilePhotoCamera => 'Camera';

  @override
  String get editProfilePhotoDelete => 'Delete photo';

  @override
  String get errorPermissionDenied =>
      'Permission denied. Enable access in settings.';

  @override
  String get errorEmailAlreadyInUse => 'This email is already in use';

  @override
  String get errorRequiresRecentLogin =>
      'For security reasons, please sign in again.';

  @override
  String editProfileEmailVerificationSent(String email) {
    return 'A verification email was sent to $email. Please confirm before signing in.';
  }

  @override
  String get editProfileSectionPersonal => 'Personal information';

  @override
  String get editProfileEmail => 'Email address';

  @override
  String get editProfileSectionAdditional => 'Additional information';

  @override
  String get editProfileBirthdateHint => 'Select a date of birth';

  @override
  String editProfileAge(int age) {
    return '$age years old';
  }

  @override
  String get securityPassStrengthVeryWeak => 'Very weak';

  @override
  String get securityPassStrengthWeak => 'Weak';

  @override
  String get securityPassStrengthMedium => 'Medium';

  @override
  String get securityPassStrengthStrong => 'Strong';

  @override
  String get securityPassStrengthVeryStrong => 'Very strong';

  @override
  String get securityPasswordChanged => 'Password changed successfully!';

  @override
  String get securityErrorWrongPassword => 'Current password is incorrect';

  @override
  String get securityErrorWeakPassword => 'New password is too weak';

  @override
  String get securityErrorSessionExpired =>
      'Session expired, please sign in again';

  @override
  String get securityErrorTooManyRequests =>
      'Too many attempts, please try again later';

  @override
  String get securityTips => 'Security tips';

  @override
  String get securityAccountInfo => 'Account information';

  @override
  String get securityGoogleOnlyTitle => 'Google sign-in only';

  @override
  String get securityGoogleOnlyDesc =>
      'Your account is linked to Google. Password management is handled through your Google account.';

  @override
  String get securityCurrentPassword => 'Current password';

  @override
  String get securityNewPassword => 'New password';

  @override
  String get securityErrorPasswordTooShort =>
      'Password too short (min. 6 characters)';

  @override
  String get securityConfirmPassword => 'Confirm password';

  @override
  String get securityErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get securityTipStrongTitle => 'Strong password';

  @override
  String get securityTipStrongDesc =>
      'Use at least 8 characters with letters, numbers, and symbols.';

  @override
  String get securityTipNeverShareTitle => 'Never share';

  @override
  String get securityTipNeverShareDesc =>
      'Never share your password with anyone.';

  @override
  String get securityTipChangeRegularlyTitle => 'Change regularly';

  @override
  String get securityTipChangeRegularlyDesc =>
      'Renew your password every 3 to 6 months.';

  @override
  String get securityTipTrustedDevicesTitle => 'Trusted devices';

  @override
  String get securityTipTrustedDevicesDesc =>
      'Sign out from devices you don\'t recognize.';

  @override
  String get securityTipVerifiedEmailTitle => 'Verified email';

  @override
  String get securityTipVerifiedEmailDesc =>
      'Keep your email up to date to recover your account.';

  @override
  String get securityEmail => 'Email';

  @override
  String get securityEmailVerified => 'Verified';

  @override
  String get securityEmailNotVerified => 'Not verified';

  @override
  String get securityLoginMethod => 'Login method';

  @override
  String get securityLoginGoogle => 'Google';

  @override
  String get securityLoginEmailPassword => 'Email / Password';

  @override
  String get securityUid => 'User ID';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionData => 'Data';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileTermsLabel => 'Terms of service';

  @override
  String get profilePrivacyLabel => 'Privacy policy';

  @override
  String get profileVersion => 'Version 1.0.0';

  @override
  String get profileUserFallback => 'User';

  @override
  String get profileCurrencyConvertHint =>
      'All amounts will be converted automatically';

  @override
  String get profileNoResults => 'No results';

  @override
  String get profileDeleteIrreversible => 'Irreversible action';

  @override
  String get profileDeleteErrorUserNotFound => 'User not found.';

  @override
  String get profileDeleteErrorSessionExpired =>
      'Please sign in again (session expired).';

  @override
  String get profileDeleteErrorAuth => 'Authentication error';

  @override
  String get profileDeleteErrorGeneric =>
      'An error occurred. Please try again.';

  @override
  String get backupSaveDataTitle => 'Save data';

  @override
  String get backupFormatExport => 'Export format';

  @override
  String get backupDataToInclude => 'Data to include';

  @override
  String get backupIntroText =>
      'Export your financial data as PDF or CSV. Select the desired sections and preview before downloading.';

  @override
  String get backupPdfLabel => 'Formatted report';

  @override
  String get backupCsvLabel => 'Raw data';

  @override
  String get backupSelected => 'Selected';

  @override
  String get backupFilePreview => 'File preview';

  @override
  String backupSectionsSelected(int count) {
    return '$count section(s) selected';
  }

  @override
  String get backupPreviewDownloadPdf => 'Preview & Download PDF';

  @override
  String get backupSelectAtLeastOne => 'Please select at least one section';

  @override
  String get backupCsvSuccess => 'CSV file exported successfully';

  @override
  String get backupCsvShareText => 'Here is my CSV export from Savy';

  @override
  String get backupPdfPreviewTitle => 'PDF Preview';

  @override
  String get backupPdfShareSubject => 'Savy - Financial report';

  @override
  String get backupCsvShareSubject => 'Savy - CSV Export';

  @override
  String get exportSectionBudget => 'Budget';

  @override
  String get exportSectionTransactions => 'Transactions';

  @override
  String get exportSectionObjectives => 'Objectives';

  @override
  String get exportSectionRevenues => 'Revenues';

  @override
  String get legalLastUpdated => 'Last updated: January 1, 2025';

  @override
  String get legalTermsFooter =>
      'By using Savvy, you agree to these terms. For any questions, contact us at support@savvy.app';

  @override
  String get legalPrivacyFooter =>
      'To exercise your rights or for any questions about your data, contact our DPO at privacy@savvy.app';

  @override
  String get legalTermsS1Title => '1. Acceptance of terms';

  @override
  String get legalTermsS1Content =>
      'By accessing or using the Savvy app, you agree to be bound by these Terms of Service. If you do not accept all of these terms, you are not authorized to use our services. These terms constitute a legally binding agreement between you and Savvy.';

  @override
  String get legalTermsS2Title => '2. Service description';

  @override
  String get legalTermsS2Content =>
      'Savvy is a personal finance management app that allows you to track your expenses, manage your budgets, set savings goals, and analyze your financial health. We reserve the right to modify, suspend, or discontinue all or part of the service at any time.';

  @override
  String get legalTermsS3Title => '3. Registration and account';

  @override
  String get legalTermsS3Content =>
      'To use Savvy, you must create an account by providing accurate and complete information. You are responsible for maintaining the confidentiality of your login credentials and all activities carried out under your account. You must be at least 18 years old to create an account.';

  @override
  String get legalTermsS4Title => '4. Acceptable use';

  @override
  String get legalTermsS4Content =>
      'You agree not to use Savvy for unlawful purposes, not to attempt unauthorized access to our systems, not to transmit viruses or malicious code, and not to use the service in a way that disrupts its normal operation or harms other users.';

  @override
  String get legalTermsS5Title => '5. Financial data';

  @override
  String get legalTermsS5Content =>
      'Savvy does not provide financial, legal, or tax advice. The information presented in the app is for informational purposes only. We are not responsible for the financial decisions you make based on the data displayed in the app.';

  @override
  String get legalTermsS6Title => '6. Intellectual property';

  @override
  String get legalTermsS6Content =>
      'All Savvy content, including but not limited to code, design, logos, text, and graphics, is the exclusive property of Savvy and is protected by intellectual property laws. Any unauthorized reproduction is strictly prohibited.';

  @override
  String get legalTermsS7Title => '7. Limitation of liability';

  @override
  String get legalTermsS7Content =>
      'To the extent permitted by applicable law, Savvy shall not be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use our services. Our total liability may not exceed the amount paid for the service in the past 12 months.';

  @override
  String get legalTermsS8Title => '8. Changes to terms';

  @override
  String get legalTermsS8Content =>
      'We reserve the right to modify these terms at any time. Changes take effect upon publication in the app. Your continued use of the service after publication constitutes your acceptance of the new terms. We will notify you of significant changes by email.';

  @override
  String get legalPrivacyS1Title => '1. Data collected';

  @override
  String get legalPrivacyS1Content =>
      'We collect information you provide directly: name, email address, and financial data you enter in the app. We also automatically collect usage data, device information, and browsing data to improve our services.';

  @override
  String get legalPrivacyS2Title => '2. Data use';

  @override
  String get legalPrivacyS2Content =>
      'Your data is used to provide and improve our services, personalize your experience, send service-related communications, ensure account security, and respond to your support requests. We never use your financial data for advertising purposes.';

  @override
  String get legalPrivacyS3Title => '3. Data sharing';

  @override
  String get legalPrivacyS3Content =>
      'We never sell your personal data to third parties. We may share your information with trusted service providers who help us operate our platform (hosting, analytics), always under strict confidentiality agreements. We will disclose your data if required by law.';

  @override
  String get legalPrivacyS4Title => '4. Data security';

  @override
  String get legalPrivacyS4Content =>
      'We implement state-of-the-art technical and organizational security measures to protect your data: AES-256 encryption at rest, TLS 1.3 in transit, multi-factor authentication, and regular security audits. Your financial data is handled with the highest level of security.';

  @override
  String get legalPrivacyS5Title => '5. Data retention';

  @override
  String get legalPrivacyS5Content =>
      'We retain your personal data for as long as your account is active or as long as necessary to provide our services. After account deletion, your data is erased within 30 days, unless a longer retention period is required by law.';

  @override
  String get legalPrivacyS6Title => '6. Your rights (GDPR)';

  @override
  String get legalPrivacyS6Content =>
      'Under GDPR, you have the right of access, rectification, erasure, portability, and objection to the processing of your data. You can exercise these rights from the app settings or by contacting us. You also have the right to lodge a complaint with your national data protection authority.';

  @override
  String get legalPrivacyS7Title => '7. Cookies and trackers';

  @override
  String get legalPrivacyS7Content =>
      'We use essential cookies for app functionality and anonymized analytics cookies to understand how you use our services. You can manage your cookie preferences in the app settings. No advertising cookies are used.';

  @override
  String get legalPrivacyS8Title => '8. International transfers';

  @override
  String get legalPrivacyS8Content =>
      'Your data may be transferred and processed in countries other than your country of residence. In such cases, we ensure appropriate safeguards are in place, including through standard contractual clauses approved by the European Commission, to protect your data.';

  @override
  String get notifSettingsTitle => 'Notification settings';

  @override
  String get notifSettingsEnableAll => 'Enable all notifications';

  @override
  String get notifSettingsBudgetAlert => 'Budget alerts';

  @override
  String get notifSettingsBudgetAlertDesc =>
      'Get notified when you reach 90% of your budget';

  @override
  String get notifSettingsGoalReminder => 'Goal reminders';

  @override
  String get notifSettingsGoalReminderDesc =>
      'Reminders when your goal deadline is approaching';

  @override
  String get notifSettingsGoalCompletion => 'Goal achievements';

  @override
  String get notifSettingsGoalCompletionDesc =>
      'Celebrate when you reach a savings goal';

  @override
  String get notifSettingsSavingSuggestion => 'Saving suggestions';

  @override
  String get notifSettingsSavingSuggestionDesc =>
      'Personalized tips to help you save more';

  @override
  String get notifSettingsSectionSecurity => 'Security';

  @override
  String get notifSettingsSecurityAlert => 'Security alerts';

  @override
  String get notifSettingsSecurityAlertDesc =>
      'Receive a push notification when your password is changed';

  @override
  String get notificationsPageTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsEmptyDesc =>
      'You\'ll see your alerts and reminders here';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get notificationsDeleteTitle => 'Delete notification';

  @override
  String get notificationsDeleteDesc =>
      'This notification will be permanently removed.';

  @override
  String get notificationsDeleteAllTitle => 'Clear all notifications';

  @override
  String get notificationsDeleteAllDesc =>
      'All your notifications will be permanently removed.';

  @override
  String get notificationsCancel => 'Cancel';

  @override
  String get notificationsDelete => 'Delete';

  @override
  String get notificationsDeleteAll => 'Clear all';

  @override
  String get notifTimeJustNow => 'Just now';

  @override
  String notifTimeMinutes(int n) {
    return '${n}m ago';
  }

  @override
  String notifTimeHours(int n) {
    return '${n}h ago';
  }

  @override
  String notifTimeDays(int n) {
    return '${n}d ago';
  }
}
