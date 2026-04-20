// ══════════════════════════════════════════════════════════════
//  SAVVY – FAQ MODELS
//  lib/models/faq_models.dart
// ══════════════════════════════════════════════════════════════

class FaqCategory {
  final String title;
  final String iconName;
  final int colorValue;
  final List<FaqItem> items;

  const FaqCategory({
    required this.title,
    required this.iconName,
    required this.colorValue,
    required this.items,
  });
}

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

// ── Locale-aware FAQ data ─────────────────────────────────────
List<FaqCategory> faqDataFor(String languageCode) {
  switch (languageCode) {
    case 'en':
      return _faqEn;
    case 'ar':
      return _faqAr;
    default:
      return _faqFr;
  }
}

// ── French ────────────────────────────────────────────────────
final List<FaqCategory> _faqFr = [
  FaqCategory(
    title: 'Démarrage',
    iconName: 'rocket',
    colorValue: 0xFF3EFFA8,
    items: [
      FaqItem(
        question: 'Comment créer mon compte Savy ?',
        answer: 'Téléchargez l\'application, appuyez sur "S\'inscrire", renseignez votre nom, email et mot de passe. Vous pouvez aussi vous connecter directement avec votre compte Google.',
      ),
      FaqItem(
        question: 'Comment me connecter à mon compte ?',
        answer: 'Sur l\'écran de connexion, entrez votre email et mot de passe puis appuyez sur "Se connecter". Vous pouvez aussi utiliser le bouton "Continuer avec Google".',
      ),
      FaqItem(
        question: 'J\'ai oublié mon mot de passe, que faire ?',
        answer: 'Sur l\'écran de connexion, appuyez sur "Mot de passe oublié ?", entrez votre email et vous recevrez un lien de réinitialisation dans votre boîte mail.',
      ),
      FaqItem(
        question: 'L\'application est-elle gratuite ?',
        answer: 'Oui, Savy est entièrement gratuite. Toutes les fonctionnalités de gestion budgétaire, suivi des dépenses et objectifs d\'épargne sont accessibles sans abonnement.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Budget & Dépenses',
    iconName: 'wallet',
    colorValue: 0xFF00D4FF,
    items: [
      FaqItem(
        question: 'Comment ajouter une dépense ?',
        answer: 'Allez dans l\'onglet "Budget", appuyez sur le bouton "Ajouter" ou le bouton flottant "Nouvelle dépense". Sélectionnez le type (Dépense/Revenu), entrez le montant et une description.',
      ),
      FaqItem(
        question: 'Comment définir un budget par catégorie ?',
        answer: 'Dans l\'onglet "Budget", chaque catégorie affiche votre budget alloué. Appuyez sur une catégorie pour la modifier. Les barres de progression montrent votre utilisation en temps réel.',
      ),
      FaqItem(
        question: 'Que se passe-t-il quand je dépasse mon budget ?',
        answer: 'La barre de progression devient rouge et un badge "Dépassé !" apparaît sur la catégorie concernée. Vous recevrez également une notification d\'alerte.',
      ),
      FaqItem(
        question: 'Comment ajouter un revenu ?',
        answer: 'Dans l\'onglet "Budget", allez sur l\'onglet "Revenus". Vos sources de revenus sont listées avec leur montant et fréquence (Mensuel, Hebdomadaire, Irrégulier).',
      ),
      FaqItem(
        question: 'Comment supprimer une transaction ?',
        answer: 'Dans l\'onglet "Dépenses", faites glisser la transaction vers la gauche pour faire apparaître l\'option de suppression, puis confirmez.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Objectifs d\'épargne',
    iconName: 'flag',
    colorValue: 0xFFFFB340,
    items: [
      FaqItem(
        question: 'Comment créer un objectif d\'épargne ?',
        answer: 'Allez dans l\'onglet "Objectifs", appuyez sur le bouton "Nouvel objectif". Renseignez le nom, le montant cible et la date limite. L\'app calculera automatiquement le montant mensuel à épargner.',
      ),
      FaqItem(
        question: 'Comment fonctionne la suggestion d\'épargne ?',
        answer: 'Savy analyse votre budget disponible et vos objectifs actifs pour vous proposer un montant optimal à épargner chaque mois. Vous pouvez accepter, modifier ou ignorer cette suggestion.',
      ),
      FaqItem(
        question: 'Puis-je avoir plusieurs objectifs en même temps ?',
        answer: 'Oui, vous pouvez créer autant d\'objectifs que vous souhaitez. Vous pouvez les classer par priorité pour que Savy optimise les suggestions en conséquence.',
      ),
      FaqItem(
        question: 'Comment modifier la priorité d\'un objectif ?',
        answer: 'Dans l\'onglet "Objectifs", le numéro en haut à gauche de chaque carte indique sa priorité. Appuyez sur le bouton de tri en haut à droite pour réorganiser vos objectifs.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Profil & Compte',
    iconName: 'person',
    colorValue: 0xFF7B61FF,
    items: [
      FaqItem(
        question: 'Comment modifier mes informations personnelles ?',
        answer: 'Allez dans l\'onglet "Profil", appuyez sur "Modifier le profil". Vous pouvez y changer votre nom, email, photo de profil, genre et date de naissance.',
      ),
      FaqItem(
        question: 'Comment changer ma photo de profil ?',
        answer: 'Dans "Modifier le profil", appuyez sur l\'avatar en haut. Choisissez de prendre une photo avec la caméra ou de sélectionner une image depuis votre galerie.',
      ),
      FaqItem(
        question: 'Comment changer mon mot de passe ?',
        answer: 'Dans l\'onglet "Profil", appuyez sur "Sécurité et mot de passe". Entrez votre mot de passe actuel puis votre nouveau mot de passe deux fois pour confirmer.',
      ),
      FaqItem(
        question: 'Comment supprimer mon compte ?',
        answer: 'Pour supprimer votre compte, contactez-nous à support@savy.app. La suppression est définitive et toutes vos données seront effacées sous 30 jours.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Données & Confidentialité',
    iconName: 'shield',
    colorValue: 0xFFFF5C7A,
    items: [
      FaqItem(
        question: 'Mes données financières sont-elles sécurisées ?',
        answer: 'Oui, toutes vos données sont chiffrées et stockées de manière sécurisée sur Firebase. Nous n\'avons jamais accès à vos données bancaires réelles.',
      ),
      FaqItem(
        question: 'Comment exporter mes données ?',
        answer: 'Dans l\'onglet "Profil" → section "Données" → "Exporter en CSV". Un fichier contenant toutes vos transactions sera généré et partageable.',
      ),
      FaqItem(
        question: 'L\'app fonctionne-t-elle hors connexion ?',
        answer: 'Savy nécessite une connexion internet pour synchroniser vos données. Les données saisies hors connexion seront synchronisées automatiquement dès que vous serez reconnecté.',
      ),
    ],
  ),
];

// ── English ───────────────────────────────────────────────────
final List<FaqCategory> _faqEn = [
  FaqCategory(
    title: 'Getting Started',
    iconName: 'rocket',
    colorValue: 0xFF3EFFA8,
    items: [
      FaqItem(
        question: 'How do I create my Savy account?',
        answer: 'Download the app, tap "Sign up", enter your name, email and password. You can also sign in directly with your Google account.',
      ),
      FaqItem(
        question: 'How do I log into my account?',
        answer: 'On the login screen, enter your email and password then tap "Log in". You can also use the "Continue with Google" button.',
      ),
      FaqItem(
        question: 'I forgot my password, what should I do?',
        answer: 'On the login screen, tap "Forgot password?", enter your email and you\'ll receive a reset link in your inbox.',
      ),
      FaqItem(
        question: 'Is the app free?',
        answer: 'Yes, Savy is completely free. All budget management, expense tracking and savings goal features are available with no subscription.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Budget & Expenses',
    iconName: 'wallet',
    colorValue: 0xFF00D4FF,
    items: [
      FaqItem(
        question: 'How do I add an expense?',
        answer: 'Go to the "Budget" tab, tap the "Add" button or the "New expense" floating button. Select the type (Expense/Income), enter the amount and a description.',
      ),
      FaqItem(
        question: 'How do I set a budget per category?',
        answer: 'In the "Budget" tab, each category shows your allocated budget. Tap a category to edit it. Progress bars show your real-time usage.',
      ),
      FaqItem(
        question: 'What happens when I exceed my budget?',
        answer: 'The progress bar turns red and an "Exceeded!" badge appears on the affected category. You will also receive an alert notification.',
      ),
      FaqItem(
        question: 'How do I add income?',
        answer: 'In the "Budget" tab, go to the "Revenue" tab. Your income sources are listed with their amount and frequency (Monthly, Weekly, Irregular).',
      ),
      FaqItem(
        question: 'How do I delete a transaction?',
        answer: 'In the "Expenses" tab, swipe the transaction to the left to reveal the delete option, then confirm.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Savings Goals',
    iconName: 'flag',
    colorValue: 0xFFFFB340,
    items: [
      FaqItem(
        question: 'How do I create a savings goal?',
        answer: 'Go to the "Goals" tab, tap "New goal". Enter the name, target amount and deadline. The app will automatically calculate the monthly savings amount.',
      ),
      FaqItem(
        question: 'How does the savings suggestion work?',
        answer: 'Savy analyzes your available budget and active goals to suggest an optimal monthly savings amount. You can accept, modify or ignore this suggestion.',
      ),
      FaqItem(
        question: 'Can I have multiple goals at the same time?',
        answer: 'Yes, you can create as many goals as you like. You can rank them by priority so Savy optimizes suggestions accordingly.',
      ),
      FaqItem(
        question: 'How do I change a goal\'s priority?',
        answer: 'In the "Goals" tab, the number at the top left of each card indicates its priority. Tap the sort button at the top right to reorganize your goals.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Profile & Account',
    iconName: 'person',
    colorValue: 0xFF7B61FF,
    items: [
      FaqItem(
        question: 'How do I edit my personal information?',
        answer: 'Go to the "Profile" tab, tap "Edit profile". You can change your name, email, profile picture, gender and date of birth.',
      ),
      FaqItem(
        question: 'How do I change my profile picture?',
        answer: 'In "Edit profile", tap the avatar at the top. Choose to take a photo with the camera or select an image from your gallery.',
      ),
      FaqItem(
        question: 'How do I change my password?',
        answer: 'In the "Profile" tab, tap "Security & password". Enter your current password then your new password twice to confirm.',
      ),
      FaqItem(
        question: 'How do I delete my account?',
        answer: 'To delete your account, contact us at support@savy.app. Deletion is permanent and all your data will be erased within 30 days.',
      ),
    ],
  ),
  FaqCategory(
    title: 'Data & Privacy',
    iconName: 'shield',
    colorValue: 0xFFFF5C7A,
    items: [
      FaqItem(
        question: 'Is my financial data secure?',
        answer: 'Yes, all your data is encrypted and securely stored on Firebase. We never have access to your actual banking data.',
      ),
      FaqItem(
        question: 'How do I export my data?',
        answer: 'In the "Profile" tab → "Data" section → "Export to CSV". A file containing all your transactions will be generated and shareable.',
      ),
      FaqItem(
        question: 'Does the app work offline?',
        answer: 'Savy requires an internet connection to sync your data. Data entered offline will be automatically synchronized once you are reconnected.',
      ),
    ],
  ),
];

// ── Arabic ────────────────────────────────────────────────────
final List<FaqCategory> _faqAr = [
  FaqCategory(
    title: 'البدء',
    iconName: 'rocket',
    colorValue: 0xFF3EFFA8,
    items: [
      FaqItem(
        question: 'كيف أنشئ حسابي في Savy؟',
        answer: 'قم بتنزيل التطبيق، اضغط على "إنشاء حساب"، أدخل اسمك وبريدك الإلكتروني وكلمة المرور. يمكنك أيضاً تسجيل الدخول مباشرةً بحسابك على Google.',
      ),
      FaqItem(
        question: 'كيف أسجّل الدخول إلى حسابي؟',
        answer: 'في شاشة تسجيل الدخول، أدخل بريدك الإلكتروني وكلمة المرور ثم اضغط "تسجيل الدخول". يمكنك أيضاً استخدام زر "المتابعة مع Google".',
      ),
      FaqItem(
        question: 'نسيت كلمة المرور، ماذا أفعل؟',
        answer: 'في شاشة تسجيل الدخول، اضغط على "نسيت كلمة المرور؟"، أدخل بريدك الإلكتروني وستصلك رسالة إعادة التعيين في صندوق بريدك.',
      ),
      FaqItem(
        question: 'هل التطبيق مجاني؟',
        answer: 'نعم، Savy مجاني تماماً. جميع ميزات إدارة الميزانية وتتبع المصاريف وأهداف الادخار متاحة دون اشتراك.',
      ),
    ],
  ),
  FaqCategory(
    title: 'الميزانية والمصاريف',
    iconName: 'wallet',
    colorValue: 0xFF00D4FF,
    items: [
      FaqItem(
        question: 'كيف أضيف مصروفاً؟',
        answer: 'انتقل إلى تبويب "الميزانية"، اضغط على زر "إضافة" أو زر "مصروف جديد". حدد النوع (مصروف/دخل)، أدخل المبلغ ووصفاً.',
      ),
      FaqItem(
        question: 'كيف أحدد ميزانية لكل فئة؟',
        answer: 'في تبويب "الميزانية"، تعرض كل فئة ميزانيتك المخصصة. اضغط على فئة لتعديلها. تُظهر أشرطة التقدم استخدامك في الوقت الفعلي.',
      ),
      FaqItem(
        question: 'ماذا يحدث عند تجاوزي الميزانية؟',
        answer: 'يتحول شريط التقدم إلى الأحمر ويظهر شارة "تجاوز!" على الفئة المعنية. ستتلقى أيضاً إشعار تنبيه.',
      ),
      FaqItem(
        question: 'كيف أضيف دخلاً؟',
        answer: 'في تبويب "الميزانية"، انتقل إلى تبويب "الدخل". تُدرج مصادر دخلك بمبالغها وتكرارها (شهري، أسبوعي، غير منتظم).',
      ),
      FaqItem(
        question: 'كيف أحذف معاملة؟',
        answer: 'في تبويب "المصاريف"، اسحب المعاملة يساراً لإظهار خيار الحذف، ثم تأكّد.',
      ),
    ],
  ),
  FaqCategory(
    title: 'أهداف الادخار',
    iconName: 'flag',
    colorValue: 0xFFFFB340,
    items: [
      FaqItem(
        question: 'كيف أنشئ هدف ادخار؟',
        answer: 'انتقل إلى تبويب "الأهداف"، اضغط "هدف جديد". أدخل الاسم والمبلغ المستهدف والموعد النهائي. سيحسب التطبيق تلقائياً المبلغ الشهري للادخار.',
      ),
      FaqItem(
        question: 'كيف تعمل اقتراحات الادخار؟',
        answer: 'يُحلّل Savy ميزانيتك المتاحة وأهدافك النشطة ليقترح مبلغاً أمثل للادخار كل شهر. يمكنك قبول الاقتراح أو تعديله أو تجاهله.',
      ),
      FaqItem(
        question: 'هل يمكنني امتلاك عدة أهداف في آن واحد؟',
        answer: 'نعم، يمكنك إنشاء أي عدد من الأهداف. يمكنك ترتيبها حسب الأولوية ليُحسّن Savy الاقتراحات وفقاً لذلك.',
      ),
      FaqItem(
        question: 'كيف أغيّر أولوية هدف؟',
        answer: 'في تبويب "الأهداف"، يُشير الرقم في أعلى يسار كل بطاقة إلى أولويته. اضغط زر الترتيب في أعلى اليمين لإعادة تنظيم أهدافك.',
      ),
    ],
  ),
  FaqCategory(
    title: 'الملف الشخصي والحساب',
    iconName: 'person',
    colorValue: 0xFF7B61FF,
    items: [
      FaqItem(
        question: 'كيف أعدّل معلوماتي الشخصية؟',
        answer: 'انتقل إلى تبويب "الملف الشخصي"، اضغط "تعديل الملف". يمكنك تغيير اسمك وبريدك الإلكتروني وصورة الملف والجنس وتاريخ الميلاد.',
      ),
      FaqItem(
        question: 'كيف أغيّر صورة ملفي الشخصي؟',
        answer: 'في "تعديل الملف"، اضغط على الصورة الرمزية في الأعلى. اختر التقاط صورة بالكاميرا أو تحديد صورة من معرض الصور.',
      ),
      FaqItem(
        question: 'كيف أغيّر كلمة المرور؟',
        answer: 'في تبويب "الملف الشخصي"، اضغط "الأمان وكلمة المرور". أدخل كلمة مرورك الحالية ثم كلمة المرور الجديدة مرتين للتأكيد.',
      ),
      FaqItem(
        question: 'كيف أحذف حسابي؟',
        answer: 'لحذف حسابك، تواصل معنا على support@savy.app. الحذف نهائي وستُمسح جميع بياناتك خلال 30 يوماً.',
      ),
    ],
  ),
  FaqCategory(
    title: 'البيانات والخصوصية',
    iconName: 'shield',
    colorValue: 0xFFFF5C7A,
    items: [
      FaqItem(
        question: 'هل بياناتي المالية آمنة؟',
        answer: 'نعم، جميع بياناتك مشفّرة ومخزّنة بشكل آمن على Firebase. لا نصل أبداً إلى بياناتك المصرفية الفعلية.',
      ),
      FaqItem(
        question: 'كيف أصدّر بياناتي؟',
        answer: 'في تبويب "الملف الشخصي" ← قسم "البيانات" ← "تصدير بصيغة CSV". سيُنشأ ملف يحتوي على جميع معاملاتك ويمكن مشاركته.',
      ),
      FaqItem(
        question: 'هل يعمل التطبيق بدون اتصال؟',
        answer: 'يحتاج Savy إلى اتصال بالإنترنت لمزامنة بياناتك. ستتم مزامنة البيانات المُدخلة بدون اتصال تلقائياً فور إعادة الاتصال.',
      ),
    ],
  ),
];

// ── Contact options ───────────────────────────────────────────
class ContactOption {
  final String title;
  final String subtitle;
  final String iconName;
  final int colorValue;
  final String action;

  const ContactOption({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorValue,
    required this.action,
  });
}

class UserReview {
  final int rating;
  final String message;
  final String userName;
  final String userEmail;
  final DateTime timestamp;

  UserReview({
    required this.rating,
    required this.message,
    required this.userName,
    required this.userEmail,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'message': message,
      'userName': userName,
      'userEmail': userEmail,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

final List<ContactOption> contactOptions = [
  ContactOption(
    title: 'Email support',
    subtitle: 'support@savy.app',
    iconName: 'email',
    colorValue: 0xFF3EFFA8,
    action: 'mailto:support@savy.app',
  ),
];
