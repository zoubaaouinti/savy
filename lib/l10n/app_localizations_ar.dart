// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Savy';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get loading => 'جار التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get finish => 'إنهاء';

  @override
  String get optional => 'اختياري';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get errorNetwork => 'خطأ في الشبكة، حاول مرة أخرى';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorInvalidEmail => 'عنوان البريد الإلكتروني غير صالح';

  @override
  String get errorInvalidAmount => 'المبلغ غير صالح';

  @override
  String get errorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get langPickerTitle => 'اختر اللغة';

  @override
  String get langFr => 'Français';

  @override
  String get langEn => 'English';

  @override
  String get langAr => 'العربية';

  @override
  String get loginWelcome => 'مرحباً بك 👋';

  @override
  String get loginSubtitle => 'سجّل الدخول إلى حسابك';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'example@email.com';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordHint => 'كلمة المرور الخاصة بك';

  @override
  String get loginForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟';

  @override
  String get loginSignupLink => 'إنشاء حساب';

  @override
  String get loginOr => 'أو تابع باستخدام';

  @override
  String get loginGoogle => 'المتابعة مع Google';

  @override
  String get loginErrorEmpty => 'يرجى ملء جميع الحقول';

  @override
  String get loginErrorInvalidEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get loginErrorWrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get loginErrorUserNotFound =>
      'لم يتم العثور على حساب بهذا البريد الإلكتروني';

  @override
  String get loginErrorTooManyRequests => 'محاولات كثيرة، حاول مرة أخرى لاحقاً';

  @override
  String get loginErrorEmailNotVerified => 'البريد الإلكتروني غير مفعّل';

  @override
  String get loginVerifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get loginVerifyEmailMessage => 'تم إرسال رسالة تحقق إلى';

  @override
  String get loginVerifyEmailResend => 'إعادة إرسال البريد';

  @override
  String get loginVerifyEmailDone => 'لقد تحققت';

  @override
  String loginVerifyEmailCooldown(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get loginResendSuccess => 'تم إعادة إرسال بريد التحقق!';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل عنوان بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.';

  @override
  String get forgotPasswordEmailLabel => 'البريد الإلكتروني';

  @override
  String get forgotPasswordSend => 'إرسال الرابط';

  @override
  String get forgotPasswordSuccess => 'تم إرسال رسالة إعادة التعيين!';

  @override
  String get forgotPasswordBack => 'العودة إلى تسجيل الدخول';

  @override
  String get signupTitle => 'إنشاء حساب';

  @override
  String get signupSubtitle => 'انضم إلى Savy وأدر مدخراتك';

  @override
  String get signupNameLabel => 'الاسم الكامل';

  @override
  String get signupNameHint => 'اسمك';

  @override
  String get signupEmailLabel => 'البريد الإلكتروني';

  @override
  String get signupEmailHint => 'example@email.com';

  @override
  String get signupPasswordLabel => 'كلمة المرور';

  @override
  String get signupPasswordHint => '٨ أحرف على الأقل';

  @override
  String get signupConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get signupConfirmPasswordHint => 'كرر كلمة المرور';

  @override
  String get signupButton => 'إنشاء حساب';

  @override
  String get signupAlreadyAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get signupLoginLink => 'تسجيل الدخول';

  @override
  String get signupAcceptTerms => 'أوافق على';

  @override
  String get signupTerms => 'شروط الاستخدام';

  @override
  String get signupAnd => 'و';

  @override
  String get signupPrivacy => 'سياسة الخصوصية';

  @override
  String get signupPasswordStrength => 'قوة كلمة المرور:';

  @override
  String get signupPasswordWeak => 'ضعيفة';

  @override
  String get signupPasswordMedium => 'متوسطة';

  @override
  String get signupPasswordGood => 'جيدة';

  @override
  String get signupPasswordExcellent => 'ممتازة';

  @override
  String get signupErrorName => 'يرجى إدخال اسمك';

  @override
  String get signupErrorEmail => 'بريد إلكتروني غير صالح';

  @override
  String get signupErrorPassword => 'كلمة المرور قصيرة جداً (٨ أحرف على الأقل)';

  @override
  String get signupErrorConfirm => 'كلمتا المرور غير متطابقتين';

  @override
  String get signupErrorTerms => 'يرجى قبول الشروط والأحكام';

  @override
  String get signupErrorEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل';

  @override
  String get signupEmailSentTitle => 'تم إرسال البريد! 📬';

  @override
  String signupEmailSentMessage(String email) {
    return 'تم إرسال رسالة تحقق إلى $email. تحقق من بريدك الإلكتروني قبل تسجيل الدخول.';
  }

  @override
  String get signupEmailSentButton => 'الذهاب إلى تسجيل الدخول';

  @override
  String get signupGoogle => 'المتابعة مع Google';

  @override
  String get onboardingNameTitle => 'ما اسمك الأول؟';

  @override
  String get onboardingNameSubtitle => 'مرحباً بك في Savy! لنبدأ بالتعارف.';

  @override
  String get onboardingNameHint => 'أدخل اسمك الأول';

  @override
  String get onboardingNameError => 'يرجى إدخال اسمك الأول';

  @override
  String get onboardingNameNext => 'متابعة';

  @override
  String get onboardingBalanceTitle => 'رصيدك الابتدائي';

  @override
  String get onboardingBalanceSubtitle =>
      'ما هو رصيدك الحالي؟ يمكنك تغييره لاحقاً.';

  @override
  String get onboardingBalanceHint => '٠٫٠٠';

  @override
  String get onboardingBalanceCurrency => 'العملة';

  @override
  String get onboardingBalanceFinish => 'ابدأ الآن';

  @override
  String get onboardingBalanceError => 'يرجى إدخال مبلغ صالح';

  @override
  String get homeHello => 'مرحباً،';

  @override
  String get homeSubtitle => 'إليك لوحة التحكم الخاصة بك';

  @override
  String get homeTotalBalance => 'الرصيد الإجمالي';

  @override
  String get homeBudgetUsed => 'من ميزانيتك مستخدمة';

  @override
  String get homeHealthScore => 'درجة الصحة المالية';

  @override
  String get homeIncome => 'الدخل';

  @override
  String get homeExpenses => 'المصاريف';

  @override
  String get homeMyObjectives => 'أهدافي';

  @override
  String get homeRecentTransactions => 'المعاملات الأخيرة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeNoObjectives => 'لا توجد أهداف';

  @override
  String get homeNoObjectivesHint => 'أنشئ هدفك الأول للادخار';

  @override
  String get homeNoTransactions => 'لا توجد معاملات';

  @override
  String get homeScoreExcellent => 'ممتاز';

  @override
  String get homeScoreGood => 'جيد';

  @override
  String get homeScoreAverage => 'متوسط';

  @override
  String get homeScorePoor => 'يحتاج تحسين';

  @override
  String homeObjectiveProgress(String percent) {
    return '$percent% محقق';
  }

  @override
  String get budgetTitle => 'الميزانية';

  @override
  String get budgetSubtitle => 'أدر مصاريفك';

  @override
  String get budgetTabBudget => 'الميزانية';

  @override
  String get budgetTabRevenues => 'الدخل';

  @override
  String get budgetTotal => 'إجمالي الميزانية';

  @override
  String get budgetSpent => 'المنفق';

  @override
  String get budgetRemaining => 'المتبقي';

  @override
  String get budgetAddCategory => 'إضافة فئة';

  @override
  String get budgetAddRevenue => 'إضافة دخل';

  @override
  String get budgetNoCategoryTitle => 'لا توجد فئات';

  @override
  String get budgetNoCategoryHint => 'اضغط + لإضافة أول ميزانية';

  @override
  String get budgetNoRevenueTitle => 'لا يوجد دخل';

  @override
  String get budgetNoRevenueHint => 'اضغط + لإضافة أول دخل';

  @override
  String get budgetDeleteCategory => 'حذف الفئة';

  @override
  String get budgetDeleteRevenue => 'حذف الدخل';

  @override
  String get budgetDeleteConfirm => 'هل تريد حذف';

  @override
  String get budgetDeleteSuccess => 'تم الحذف بنجاح';

  @override
  String get budgetCategoryBudget => 'الميزانية';

  @override
  String get budgetCategorySpent => 'المنفق';

  @override
  String get budgetCategoryRemaining => 'المتبقي';

  @override
  String get budgetAddTransaction => 'إضافة مصروف';

  @override
  String get budgetTransactionLabel => 'التسمية';

  @override
  String get budgetTransactionAmount => 'المبلغ';

  @override
  String get budgetTransactionNote => 'ملاحظة';

  @override
  String get budgetTransactionDate => 'التاريخ';

  @override
  String get budgetTransactionAdd => 'إضافة المصروف';

  @override
  String get budgetRevenueSource => 'المصدر';

  @override
  String get budgetRevenueAmount => 'المبلغ';

  @override
  String get budgetRevenueType => 'النوع';

  @override
  String get budgetRevenueAdd => 'إضافة الدخل';

  @override
  String get budgetNewCategory => 'فئة جديدة';

  @override
  String get budgetCategoryName => 'اسم الفئة';

  @override
  String get budgetCategoryBudgetLabel => 'الميزانية (شهرية)';

  @override
  String get budgetCategoryCreate => 'إنشاء';

  @override
  String get budgetCategoryIcon => 'أيقونة';

  @override
  String get budgetCategoryColor => 'اللون';

  @override
  String get budgetOverspent => 'تجاوز الميزانية';

  @override
  String budgetPercent(String percent) {
    return '$percent%';
  }

  @override
  String get catFood => 'الغذاء';

  @override
  String get catTransport => 'المواصلات';

  @override
  String get catLeisure => 'الترفيه';

  @override
  String get catAcademic => 'التعليم';

  @override
  String get catHealth => 'الصحة';

  @override
  String get catOther => 'أخرى';

  @override
  String get objectivesTitle => 'الأهداف';

  @override
  String get objectivesSubtitle => 'أهداف الادخار الخاصة بك';

  @override
  String get objectivesTotalSavings => 'إجمالي المدخرات';

  @override
  String get objectivesAdd => 'هدف جديد';

  @override
  String get objectivesEmpty => 'لا توجد أهداف بعد';

  @override
  String get objectivesEmptyHint => 'اضغط + لإنشاء هدف';

  @override
  String objectivesCount(int count) {
    return '$count هدف';
  }

  @override
  String objectivesCountPlural(int count) {
    return '$count أهداف';
  }

  @override
  String get objectivesDeleteTitle => 'حذف الهدف';

  @override
  String objectivesDeleteConfirm(String name) {
    return 'هل تريد حذف \"$name\"؟';
  }

  @override
  String get objectivesAmountToAdd => 'المبلغ المراد إضافته';

  @override
  String get objectivesFeedTitle => 'تمويل الهدف';

  @override
  String get objectivesConfirmPayment => 'تأكيد الدفع';

  @override
  String get objectivesMissing => 'المتبقي:';

  @override
  String get objectivesReached => '% محقق';

  @override
  String get objectivesCompleted => 'تم تحقيق الهدف! 🎉';

  @override
  String objectivesAddedSuccess(String amount, String name) {
    return '+ $amount أضيفت إلى \"$name\"';
  }

  @override
  String get objectivesName => 'اسم الهدف';

  @override
  String get objectivesNameHint => 'مثال: سيارة، رحلة...';

  @override
  String get objectivesTarget => 'المبلغ المستهدف';

  @override
  String get objectivesSaved => 'المدخر حتى الآن';

  @override
  String get objectivesDeadline => 'تاريخ الانتهاء';

  @override
  String get objectivesPriority => 'الأولوية';

  @override
  String get objectivesColor => 'اللون';

  @override
  String get objectivesIcon => 'الأيقونة';

  @override
  String get objectivesCreate => 'إنشاء الهدف';

  @override
  String get objectivesSortTitle => 'ترتيب الأهداف';

  @override
  String get objectivesSortSubtitle => 'اختر ترتيب العرض';

  @override
  String get objectivesSortByDate => 'حسب التاريخ';

  @override
  String get objectivesSortDateDesc => 'الأحدث → الأقدم';

  @override
  String get objectivesSortDateAsc => 'الأقدم → الأحدث';

  @override
  String get objectivesSortDateDescSub => 'الأحدث أولاً';

  @override
  String get objectivesSortDateAscSub => 'الأقدم أولاً';

  @override
  String get objectivesSortByPriority => 'حسب الأولوية';

  @override
  String get objectivesSortPriorityHighFirst => 'الأولوية: عالية → منخفضة';

  @override
  String get objectivesSortPriorityLowFirst => 'الأولوية: منخفضة → عالية';

  @override
  String get objectivesSortPriorityHighFirstSub => 'الأهم أولاً';

  @override
  String get objectivesSortPriorityLowFirstSub => 'الأقل أهمية أولاً';

  @override
  String get objectivesSortByProgress => 'حسب التقدم';

  @override
  String get objectivesSortProgressDesc => 'التقدم: الأعلى';

  @override
  String get objectivesSortProgressAsc => 'التقدم: الأدنى';

  @override
  String get objectivesSortProgressDescSub => 'الأقرب للهدف أولاً';

  @override
  String get objectivesSortProgressAscSub => 'الأقل تقدماً أولاً';

  @override
  String objectivesSuggestion(String amount) {
    return 'وفّر $amount/شهر للوصول إلى هدفك في الوقت المحدد.';
  }

  @override
  String get objectivesDeadlineLabel => 'الموعد النهائي:';

  @override
  String get objectivesPriorityLabel => 'الأولوية';

  @override
  String get objectivesAmountError => 'يرجى إدخال مبلغ';

  @override
  String get objectivesAmountInvalid => 'مبلغ غير صالح';

  @override
  String get transactionsTitle => 'المعاملات';

  @override
  String get transactionsSubtitle => 'السجل الكامل';

  @override
  String get transactionsSearch => 'البحث في المعاملات...';

  @override
  String get transactionsAll => 'الكل';

  @override
  String get transactionsExpenses => 'المصاريف';

  @override
  String get transactionsRevenues => 'الدخل';

  @override
  String get transactionsEmpty => 'لا توجد معاملات';

  @override
  String transactionsCount(int count) {
    return '$count معاملة';
  }

  @override
  String get transactionsDeleteTitle => 'حذف المعاملة';

  @override
  String get transactionsDeleteConfirm => 'هل تريد حذف';

  @override
  String get transactionsDeleteSuccess => 'تم حذف المعاملة';

  @override
  String get transactionsRevenueBadge => 'دخل';

  @override
  String get transactionsRevenueHint => 'احذف هذا الدخل من صفحة الدخل.';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileObjectivesStat => 'أهداف';

  @override
  String get profileTransactionsStat => 'معاملة';

  @override
  String get profileHealthScore => 'درجة الصحة المالية';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileCurrency => 'العملة';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileSecurity => 'الأمان';

  @override
  String get profileHelp => 'المساعدة والدعم';

  @override
  String get profileBackup => 'النسخ الاحتياطي';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutMessage => 'هل تريد تسجيل الخروج؟';

  @override
  String get profileSelectCurrency => 'اختر العملة';

  @override
  String get profileSearchCurrency => 'البحث عن عملة...';

  @override
  String get profileSelectLanguage => 'اختر اللغة';

  @override
  String get profilePhoto => 'صورة الملف الشخصي';

  @override
  String get profilePhotoGallery => 'المعرض';

  @override
  String get profilePhotoCamera => 'الكاميرا';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileName => 'الاسم الكامل';

  @override
  String get editProfileNameHint => 'اسمك';

  @override
  String get editProfileGender => 'الجنس';

  @override
  String get editProfileBirthdate => 'تاريخ الميلاد';

  @override
  String get editProfileSave => 'حفظ';

  @override
  String get editProfileSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get editProfileGenderMale => 'ذكر';

  @override
  String get editProfileGenderFemale => 'أنثى';

  @override
  String get editProfileGenderOther => 'آخر';

  @override
  String get editProfileGenderNotSpecified => 'غير محدد';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountReasonTitle => 'لماذا تريد المغادرة؟';

  @override
  String get deleteAccountReason1 => 'لم أعد أستخدم التطبيق';

  @override
  String get deleteAccountReason2 => 'التطبيق لا يلبي احتياجاتي';

  @override
  String get deleteAccountReason3 => 'مخاوف تتعلق بالخصوصية';

  @override
  String get deleteAccountReason4 => 'صعب الاستخدام';

  @override
  String get deleteAccountReason5 => 'أسباب أخرى';

  @override
  String get deleteAccountOtherHint => 'أخبرنا المزيد...';

  @override
  String get deleteAccountWarning =>
      '⚠️ هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً.';

  @override
  String get deleteAccountConfirmLabel => 'اكتب \"حذف\" للتأكيد';

  @override
  String get deleteAccountConfirmHint => 'حذف';

  @override
  String get deleteAccountConfirmWord => 'حذف';

  @override
  String get deleteAccountButton => 'حذف نهائي';

  @override
  String get deleteAccountErrorReason => 'يرجى اختيار سبب';

  @override
  String get deleteAccountErrorConfirm => 'اكتب \"حذف\" للتأكيد';

  @override
  String get deleteAccountErrorReauth =>
      'لأسباب أمنية، يرجى تسجيل الدخول مجدداً قبل حذف حسابك.';

  @override
  String get securityTitle => 'الأمان';

  @override
  String get securityChangePassword => 'تغيير كلمة المرور';

  @override
  String get securityTwoFactor => 'المصادقة الثنائية';

  @override
  String get securityActiveSessions => 'الجلسات النشطة';

  @override
  String get helpTitle => 'المساعدة والدعم';

  @override
  String get helpFaq => 'الأسئلة الشائعة';

  @override
  String get helpContact => 'تواصل معنا';

  @override
  String get helpVersion => 'الإصدار';

  @override
  String get helpScreenTitle => 'المساعدة والأسئلة الشائعة';

  @override
  String get helpChipAll => 'الكل';

  @override
  String get helpSearchHint => 'البحث في المساعدة...';

  @override
  String get helpSearchNoResults => 'لا توجد نتائج';

  @override
  String get helpSearchTryOther => 'جرّب كلمات بحث أخرى';

  @override
  String get helpContactDialogTitle => 'تواصل مع الدعم';

  @override
  String get helpContactSubject => 'الموضوع';

  @override
  String get helpContactSubjectHint => 'مثال: مشكلة في ميزانيتي...';

  @override
  String get helpContactMessage => 'الرسالة';

  @override
  String get helpContactMessageHint => 'اشرح مشكلتك بالتفصيل...';

  @override
  String get helpContactFillAll => 'يرجى ملء جميع الحقول';

  @override
  String get helpContactSend => 'إرسال';

  @override
  String get helpContactSuccessTitle => 'تم إرسال الرسالة!';

  @override
  String get helpContactSuccessBody =>
      'تم إرسال رسالتك إلى فريقنا. سنردّ عليك في أقرب وقت ممكن.';

  @override
  String get helpContactSuccessBtn => 'رائع!';

  @override
  String get helpVersionDesc => 'تطبيق إدارة الميزانية للطلاب';

  @override
  String get backupTitle => 'النسخ الاحتياطي والتصدير';

  @override
  String get backupExportPdf => 'تصدير كـ PDF';

  @override
  String get backupExportCsv => 'تصدير كـ CSV';

  @override
  String get backupLastBackup => 'آخر نسخة احتياطية';

  @override
  String get notifBudgetAlert => 'تنبيه الميزانية';

  @override
  String notifBudgetAlertBody(String percent, String category) {
    return 'لقد وصلت إلى $percent% من ميزانية $category';
  }

  @override
  String get notifObjectiveComplete => 'تم تحقيق الهدف! 🎉';

  @override
  String notifObjectiveCompleteBody(String name) {
    return 'تهانينا! لقد حققت هدف \"$name\".';
  }

  @override
  String get legalTermsTitle => 'شروط الاستخدام';

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get splashTagline => 'أدر مدخراتك بذكاء';

  @override
  String get legalScrollHint => 'مرر للقراءة';

  @override
  String get legalAcceptTerms => 'أقبل الشروط';

  @override
  String get legalAcceptPrivacy => 'أقبل السياسة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navBudget => 'الميزانية';

  @override
  String get navObjectives => 'الأهداف';

  @override
  String get navExpenses => 'المصاريف';

  @override
  String get navProfile => 'الملف';

  @override
  String get editProfilePhotoTitle => 'صورة الملف الشخصي';

  @override
  String get editProfilePhotoGallery => 'المعرض';

  @override
  String get editProfilePhotoCamera => 'الكاميرا';

  @override
  String get editProfilePhotoDelete => 'حذف الصورة';

  @override
  String get errorPermissionDenied => 'تم رفض الإذن. فعّل الوصول في الإعدادات.';

  @override
  String get errorEmailAlreadyInUse => 'هذا البريد الإلكتروني مستخدم بالفعل';

  @override
  String get errorRequiresRecentLogin =>
      'لأسباب أمنية، يرجى تسجيل الدخول مجدداً.';

  @override
  String editProfileEmailVerificationSent(String email) {
    return 'تم إرسال رسالة تحقق إلى $email. قم بالتأكيد قبل تسجيل الدخول القادم.';
  }

  @override
  String get editProfileSectionPersonal => 'المعلومات الشخصية';

  @override
  String get editProfileEmail => 'البريد الإلكتروني';

  @override
  String get editProfileSectionAdditional => 'معلومات إضافية';

  @override
  String get editProfileBirthdateHint => 'اختر تاريخ الميلاد';

  @override
  String editProfileAge(int age) {
    return 'عمره $age سنة';
  }

  @override
  String get securityPassStrengthVeryWeak => 'ضعيف جداً';

  @override
  String get securityPassStrengthWeak => 'ضعيف';

  @override
  String get securityPassStrengthMedium => 'متوسط';

  @override
  String get securityPassStrengthStrong => 'قوي';

  @override
  String get securityPassStrengthVeryStrong => 'قوي جداً';

  @override
  String get securityPasswordChanged => 'تم تغيير كلمة المرور بنجاح!';

  @override
  String get securityErrorWrongPassword => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get securityErrorWeakPassword => 'كلمة المرور الجديدة ضعيفة جداً';

  @override
  String get securityErrorSessionExpired =>
      'انتهت الجلسة، يرجى تسجيل الدخول مجدداً';

  @override
  String get securityErrorTooManyRequests =>
      'محاولات كثيرة، حاول مرة أخرى لاحقاً';

  @override
  String get securityTips => 'نصائح الأمان';

  @override
  String get securityAccountInfo => 'معلومات الحساب';

  @override
  String get securityGoogleOnlyTitle => 'تسجيل الدخول بـ Google فقط';

  @override
  String get securityGoogleOnlyDesc =>
      'حسابك مرتبط بـ Google. تتم إدارة كلمة المرور من خلال حسابك على Google.';

  @override
  String get securityCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get securityNewPassword => 'كلمة المرور الجديدة';

  @override
  String get securityErrorPasswordTooShort =>
      'كلمة المرور قصيرة جداً (٦ أحرف على الأقل)';

  @override
  String get securityConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get securityErrorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get securityTipStrongTitle => 'كلمة مرور قوية';

  @override
  String get securityTipStrongDesc =>
      'استخدم ٨ أحرف على الأقل مع أحرف وأرقام ورموز.';

  @override
  String get securityTipNeverShareTitle => 'لا تشارك أبداً';

  @override
  String get securityTipNeverShareDesc => 'لا تشارك كلمة مرورك مع أي شخص.';

  @override
  String get securityTipChangeRegularlyTitle => 'غيّر بانتظام';

  @override
  String get securityTipChangeRegularlyDesc =>
      'جدّد كلمة مرورك كل ٣ إلى ٦ أشهر.';

  @override
  String get securityTipTrustedDevicesTitle => 'أجهزة موثوقة';

  @override
  String get securityTipTrustedDevicesDesc =>
      'سجّل الخروج من الأجهزة التي لا تعرفها.';

  @override
  String get securityTipVerifiedEmailTitle => 'بريد إلكتروني مفعّل';

  @override
  String get securityTipVerifiedEmailDesc =>
      'حافظ على تحديث بريدك الإلكتروني لاسترداد حسابك.';

  @override
  String get securityEmail => 'البريد الإلكتروني';

  @override
  String get securityEmailVerified => 'مفعّل';

  @override
  String get securityEmailNotVerified => 'غير مفعّل';

  @override
  String get securityLoginMethod => 'طريقة تسجيل الدخول';

  @override
  String get securityLoginGoogle => 'Google';

  @override
  String get securityLoginEmailPassword => 'بريد إلكتروني / كلمة مرور';

  @override
  String get securityUid => 'معرّف المستخدم';

  @override
  String get profileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileSectionAccount => 'الحساب';

  @override
  String get profileSectionPreferences => 'التفضيلات';

  @override
  String get profileSectionData => 'البيانات';

  @override
  String get profileSectionSupport => 'الدعم';

  @override
  String get profileTermsLabel => 'شروط الاستخدام';

  @override
  String get profilePrivacyLabel => 'سياسة الخصوصية';

  @override
  String get profileVersion => 'الإصدار 1.0.0';

  @override
  String get profileUserFallback => 'مستخدم';

  @override
  String get profileCurrencyConvertHint => 'ستُحوَّل جميع المبالغ تلقائياً';

  @override
  String get profileNoResults => 'لا توجد نتائج';

  @override
  String get profileDeleteIrreversible => 'إجراء لا رجعة فيه';

  @override
  String get profileDeleteErrorUserNotFound => 'المستخدم غير موجود.';

  @override
  String get profileDeleteErrorSessionExpired =>
      'يرجى تسجيل الدخول مجدداً (انتهت الجلسة).';

  @override
  String get profileDeleteErrorAuth => 'خطأ في المصادقة';

  @override
  String get profileDeleteErrorGeneric => 'حدث خطأ. يرجى المحاولة مجدداً.';

  @override
  String get backupSaveDataTitle => 'حفظ البيانات';

  @override
  String get backupFormatExport => 'صيغة التصدير';

  @override
  String get backupDataToInclude => 'البيانات المراد تضمينها';

  @override
  String get backupIntroText =>
      'صدِّر بياناتك المالية بصيغة PDF أو CSV. اختر الأقسام المطلوبة وقم بمعاينتها قبل التنزيل.';

  @override
  String get backupPdfLabel => 'تقرير منسق';

  @override
  String get backupCsvLabel => 'بيانات خام';

  @override
  String get backupSelected => 'محدد';

  @override
  String get backupFilePreview => 'معاينة الملف';

  @override
  String backupSectionsSelected(int count) {
    return '$count قسم مختار';
  }

  @override
  String get backupPreviewDownloadPdf => 'معاينة وتنزيل PDF';

  @override
  String get backupSelectAtLeastOne => 'الرجاء تحديد قسم واحد على الأقل';

  @override
  String get backupCsvSuccess => 'تم تصدير ملف CSV بنجاح';

  @override
  String get backupCsvShareText => 'هذا تصدير CSV من تطبيق Savy';

  @override
  String get backupPdfPreviewTitle => 'معاينة PDF';

  @override
  String get backupPdfShareSubject => 'Savy - تقرير مالي';

  @override
  String get backupCsvShareSubject => 'Savy - تصدير CSV';

  @override
  String get exportSectionBudget => 'الميزانية';

  @override
  String get exportSectionTransactions => 'المعاملات';

  @override
  String get exportSectionObjectives => 'الأهداف';

  @override
  String get exportSectionRevenues => 'الإيرادات';

  @override
  String get legalLastUpdated => 'آخر تحديث: 1 يناير 2025';

  @override
  String get legalTermsFooter =>
      'باستخدامك لـ Savvy، فأنت توافق على هذه الشروط. لأي استفسار، تواصل معنا على support@savvy.app';

  @override
  String get legalPrivacyFooter =>
      'لممارسة حقوقك أو لأي استفسار حول بياناتك، تواصل مع مسؤول حماية البيانات على privacy@savvy.app';

  @override
  String get legalTermsS1Title => '١. قبول الشروط';

  @override
  String get legalTermsS1Content =>
      'بالوصول إلى تطبيق Savvy أو استخدامه، فأنت توافق على الالتزام بشروط الخدمة هذه. إذا لم توافق على جميع الشروط، فلن يُسمح لك باستخدام خدماتنا. تُشكّل هذه الشروط اتفاقية ملزمة قانونياً بينك وبين Savvy.';

  @override
  String get legalTermsS2Title => '٢. وصف الخدمة';

  @override
  String get legalTermsS2Content =>
      'Savvy هو تطبيق لإدارة الشؤون المالية الشخصية يتيح لك تتبع نفقاتك وإدارة ميزانياتك وتحديد أهداف الادخار وتحليل صحتك المالية. نحتفظ بحق تعديل الخدمة أو تعليقها أو إيقافها كلياً أو جزئياً في أي وقت.';

  @override
  String get legalTermsS3Title => '٣. التسجيل والحساب';

  @override
  String get legalTermsS3Content =>
      'لاستخدام Savvy، يجب إنشاء حساب بتقديم معلومات دقيقة وكاملة. أنت مسؤول عن سرية بيانات تسجيل الدخول وجميع الأنشطة التي تتم تحت حسابك. يجب أن يكون عمرك 18 عاماً على الأقل لإنشاء حساب.';

  @override
  String get legalTermsS4Title => '٤. الاستخدام المقبول';

  @override
  String get legalTermsS4Content =>
      'توافق على عدم استخدام Savvy لأغراض غير قانونية، وعدم محاولة الوصول غير المصرح به إلى أنظمتنا، وعدم إرسال فيروسات أو أكواد خبيثة، وعدم استخدام الخدمة بطريقة تعطل عملها أو تضر بالمستخدمين الآخرين.';

  @override
  String get legalTermsS5Title => '٥. البيانات المالية';

  @override
  String get legalTermsS5Content =>
      'لا يقدم Savvy مشورة مالية أو قانونية أو ضريبية. المعلومات المعروضة في التطبيق هي لأغراض إعلامية فقط. لسنا مسؤولين عن القرارات المالية التي تتخذها بناءً على البيانات المعروضة في التطبيق.';

  @override
  String get legalTermsS6Title => '٦. الملكية الفكرية';

  @override
  String get legalTermsS6Content =>
      'جميع محتويات Savvy، بما في ذلك الكود والتصميم والشعارات والنصوص والرسومات، هي ملك حصري لـ Savvy ومحمية بقوانين الملكية الفكرية. يُمنع منعاً باتاً أي تكاثر غير مصرح به.';

  @override
  String get legalTermsS7Title => '٧. حدود المسؤولية';

  @override
  String get legalTermsS7Content =>
      'بالقدر المسموح به قانوناً، لن يتحمل Savvy المسؤولية عن أي أضرار غير مباشرة أو عرضية أو تبعية ناتجة عن استخدام خدماتنا أو عدم القدرة على استخدامها. إجمالي مسؤوليتنا لا يتجاوز المبلغ المدفوع للخدمة خلال الـ 12 شهراً الأخيرة.';

  @override
  String get legalTermsS8Title => '٨. تعديلات الشروط';

  @override
  String get legalTermsS8Content =>
      'نحتفظ بحق تعديل هذه الشروط في أي وقت. تدخل التعديلات حيز التنفيذ فور نشرها في التطبيق. استمرارك في استخدام الخدمة بعد النشر يُعدّ قبولاً للشروط الجديدة. سنُخطرك بالتغييرات المهمة عبر البريد الإلكتروني.';

  @override
  String get legalPrivacyS1Title => '١. البيانات المجمَّعة';

  @override
  String get legalPrivacyS1Content =>
      'نجمع المعلومات التي تقدمها مباشرةً: الاسم والبريد الإلكتروني والبيانات المالية التي تدخلها في التطبيق. كما نجمع تلقائياً بيانات الاستخدام ومعلومات الجهاز وبيانات التصفح لتحسين خدماتنا.';

  @override
  String get legalPrivacyS2Title => '٢. استخدام البيانات';

  @override
  String get legalPrivacyS2Content =>
      'تُستخدم بياناتك لتقديم خدماتنا وتحسينها وتخصيص تجربتك وإرسال الاتصالات المتعلقة بالخدمة وضمان أمان حسابك والرد على طلبات الدعم. لا نستخدم بياناتك المالية أبداً لأغراض إعلانية.';

  @override
  String get legalPrivacyS3Title => '٣. مشاركة البيانات';

  @override
  String get legalPrivacyS3Content =>
      'لا نبيع بياناتك الشخصية أبداً لأطراف ثالثة. قد نشارك معلوماتك مع مزودي خدمات موثوقين يساعدوننا في تشغيل منصتنا (الاستضافة والتحليلات)، وذلك دائماً بموجب اتفاقيات سرية صارمة. سنكشف بياناتك إذا استلزم القانون ذلك.';

  @override
  String get legalPrivacyS4Title => '٤. أمان البيانات';

  @override
  String get legalPrivacyS4Content =>
      'نُطبّق أحدث التدابير الأمنية التقنية والتنظيمية لحماية بياناتك: تشفير AES-256 في حالة الراحة وTLS 1.3 أثناء النقل والمصادقة متعددة العوامل وعمليات تدقيق أمنية منتظمة. تُعالَج بياناتك المالية بأعلى مستويات الأمان.';

  @override
  String get legalPrivacyS5Title => '٥. الاحتفاظ بالبيانات';

  @override
  String get legalPrivacyS5Content =>
      'نحتفظ ببياناتك الشخصية طالما حسابك نشط أو طالما كان ذلك ضرورياً لتقديم خدماتنا. بعد حذف حسابك، تُمحى بياناتك خلال 30 يوماً، ما لم يستلزم القانون فترة احتفاظ أطول.';

  @override
  String get legalPrivacyS6Title => '٦. حقوقك (GDPR)';

  @override
  String get legalPrivacyS6Content =>
      'وفقاً للائحة GDPR، لك حق الوصول والتصحيح والحذف والنقل والاعتراض على معالجة بياناتك. يمكنك ممارسة هذه الحقوق من إعدادات التطبيق أو بالتواصل معنا. لك أيضاً الحق في تقديم شكوى لدى هيئة حماية البيانات الوطنية.';

  @override
  String get legalPrivacyS7Title => '٧. ملفات تعريف الارتباط والمتتبعات';

  @override
  String get legalPrivacyS7Content =>
      'نستخدم ملفات تعريف ارتباط أساسية لتشغيل التطبيق وملفات تعريف ارتباط تحليلية مجهولة الهوية لفهم كيفية استخدامك لخدماتنا. يمكنك إدارة تفضيلات ملفات تعريف الارتباط في إعدادات التطبيق. لا تُستخدم ملفات تعريف ارتباط إعلانية.';

  @override
  String get legalPrivacyS8Title => '٨. التحويلات الدولية';

  @override
  String get legalPrivacyS8Content =>
      'قد يتم نقل بياناتك ومعالجتها في دول أخرى غير بلد إقامتك. في هذه الحالة، نضمن وجود ضمانات مناسبة، بما في ذلك البنود التعاقدية القياسية المعتمدة من المفوضية الأوروبية، لحماية بياناتك.';

  @override
  String get notifSettingsTitle => 'إعدادات الإشعارات';

  @override
  String get notifSettingsEnableAll => 'تفعيل جميع الإشعارات';

  @override
  String get notifSettingsBudgetAlert => 'تنبيهات الميزانية';

  @override
  String get notifSettingsBudgetAlertDesc =>
      'احصل على إشعار عند الوصول إلى 90٪ من ميزانيتك';

  @override
  String get notifSettingsGoalReminder => 'تذكيرات الأهداف';

  @override
  String get notifSettingsGoalReminderDesc =>
      'تذكيرات عند اقتراب موعد انتهاء هدفك';

  @override
  String get notifSettingsGoalCompletion => 'إنجازات الأهداف';

  @override
  String get notifSettingsGoalCompletionDesc =>
      'احتفل عند الوصول إلى هدف ادخاري';

  @override
  String get notifSettingsSavingSuggestion => 'اقتراحات الادخار';

  @override
  String get notifSettingsSavingSuggestionDesc =>
      'نصائح مخصصة لمساعدتك على ادخار أكثر';

  @override
  String get notifSettingsSectionSecurity => 'الأمان';

  @override
  String get notifSettingsSecurityAlert => 'تنبيهات الأمان';

  @override
  String get notifSettingsSecurityAlertDesc =>
      'تلقّي إشعار فوري عند تغيير كلمة المرور';

  @override
  String get notificationsPageTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptyDesc => 'ستظهر تنبيهاتك وتذكيراتك هنا';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get notificationsEarlier => 'سابقاً';

  @override
  String get notificationsDeleteTitle => 'حذف الإشعار';

  @override
  String get notificationsDeleteDesc => 'سيتم حذف هذا الإشعار نهائياً.';

  @override
  String get notificationsDeleteAllTitle => 'مسح جميع الإشعارات';

  @override
  String get notificationsDeleteAllDesc => 'سيتم حذف جميع إشعاراتك نهائياً.';

  @override
  String get notificationsCancel => 'إلغاء';

  @override
  String get notificationsDelete => 'حذف';

  @override
  String get notificationsDeleteAll => 'مسح الكل';

  @override
  String get notifTimeJustNow => 'الآن';

  @override
  String notifTimeMinutes(int n) {
    return 'منذ $n د';
  }

  @override
  String notifTimeHours(int n) {
    return 'منذ $n س';
  }

  @override
  String notifTimeDays(int n) {
    return 'منذ $n ي';
  }
}
