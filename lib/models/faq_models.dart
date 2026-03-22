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

// ── Données FAQ ───────────────────────────────────────────────
final List<FaqCategory> faqData = [
  FaqCategory(
    title: 'Démarrage',
    iconName: 'rocket',
    colorValue: 0xFF3EFFA8,
    items: [
      FaqItem(
        question: 'Comment créer mon compte Savy ?',
        answer:
        'Téléchargez l\'application, appuyez sur "S\'inscrire", renseignez votre nom, email et mot de passe. Vous pouvez aussi vous connecter directement avec votre compte Google.',
      ),
      FaqItem(
        question: 'Comment me connecter à mon compte ?',
        answer:
        'Sur l\'écran de connexion, entrez votre email et mot de passe puis appuyez sur "Se connecter". Vous pouvez aussi utiliser le bouton "Continuer avec Google".',
      ),
      FaqItem(
        question: 'J\'ai oublié mon mot de passe, que faire ?',
        answer:
        'Sur l\'écran de connexion, appuyez sur "Mot de passe oublié ?", entrez votre email et vous recevrez un lien de réinitialisation dans votre boîte mail.',
      ),
      FaqItem(
        question: 'L\'application est-elle gratuite ?',
        answer:
        'Oui, Savy est entièrement gratuite. Toutes les fonctionnalités de gestion budgétaire, suivi des dépenses et objectifs d\'épargne sont accessibles sans abonnement.',
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
        answer:
        'Allez dans l\'onglet "Budget", appuyez sur le bouton "Ajouter" ou le bouton flottant "Nouvelle dépense". Sélectionnez le type (Dépense/Revenu), entrez le montant et une description.',
      ),
      FaqItem(
        question: 'Comment définir un budget par catégorie ?',
        answer:
        'Dans l\'onglet "Budget", chaque catégorie affiche votre budget alloué. Appuyez sur une catégorie pour la modifier. Les barres de progression montrent votre utilisation en temps réel.',
      ),
      FaqItem(
        question: 'Que se passe-t-il quand je dépasse mon budget ?',
        answer:
        'La barre de progression devient rouge et un badge "Dépassé!" apparaît sur la catégorie concernée. Vous recevrez également une notification d\'alerte.',
      ),
      FaqItem(
        question: 'Comment ajouter un revenu ?',
        answer:
        'Dans l\'onglet "Budget", allez sur l\'onglet "Revenus". Vos sources de revenus sont listées avec leur montant et fréquence (Mensuel, Hebdomadaire, Irrégulier).',
      ),
      FaqItem(
        question: 'Comment supprimer une transaction ?',
        answer:
        'Dans l\'onglet "Dépenses", faites glisser la transaction vers la gauche pour faire apparaître l\'option de suppression, puis confirmez.',
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
        answer:
        'Allez dans l\'onglet "Objectifs", appuyez sur le bouton "Nouvel objectif". Renseignez le nom, le montant cible et la date limite. L\'app calculera automatiquement le montant mensuel à épargner.',
      ),
      FaqItem(
        question: 'Comment fonctionne la suggestion d\'épargne ?',
        answer:
        'Savy analyse votre budget disponible et vos objectifs actifs pour vous proposer un montant optimal à épargner chaque mois. Vous pouvez accepter, modifier ou ignorer cette suggestion.',
      ),
      FaqItem(
        question: 'Puis-je avoir plusieurs objectifs en même temps ?',
        answer:
        'Oui, vous pouvez créer autant d\'objectifs que vous souhaitez. Vous pouvez les classer par priorité pour que Savy optimise les suggestions en conséquence.',
      ),
      FaqItem(
        question: 'Comment modifier la priorité d\'un objectif ?',
        answer:
        'Dans l\'onglet "Objectifs", le numéro en haut à gauche de chaque carte indique sa priorité. Appuyez sur le bouton de tri en haut à droite pour réorganiser vos objectifs.',
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
        answer:
        'Allez dans l\'onglet "Profil", appuyez sur "Modifier le profil". Vous pouvez y changer votre nom, email, photo de profil, genre et date de naissance.',
      ),
      FaqItem(
        question: 'Comment changer ma photo de profil ?',
        answer:
        'Dans "Modifier le profil", appuyez sur l\'avatar en haut. Choisissez de prendre une photo avec la caméra ou de sélectionner une image depuis votre galerie.',
      ),
      FaqItem(
        question: 'Comment changer mon mot de passe ?',
        answer:
        'Dans l\'onglet "Profil", appuyez sur "Sécurité et mot de passe". Entrez votre mot de passe actuel puis votre nouveau mot de passe deux fois pour confirmer.',
      ),
      FaqItem(
        question: 'Comment supprimer mon compte ?',
        answer:
        'Pour supprimer votre compte, contactez-nous à support@savy.app. La suppression est définitive et toutes vos données seront effacées sous 30 jours.',
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
        answer:
        'Oui, toutes vos données sont chiffrées et stockées de manière sécurisée sur Firebase. Nous n\'avons jamais accès à vos données bancaires réelles.',
      ),
      FaqItem(
        question: 'Comment exporter mes données ?',
        answer:
        'Dans l\'onglet "Profil" → section "Données" → "Exporter en CSV". Un fichier contenant toutes vos transactions sera généré et partageable.',
      ),
      FaqItem(
        question: 'L\'app fonctionne-t-elle hors connexion ?',
        answer:
        'Savy nécessite une connexion internet pour synchroniser vos données. Les données saisies hors connexion seront synchronisées automatiquement dès que vous serez reconnecté.',
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

final List<ContactOption> contactOptions = [
  ContactOption(
    title: 'Email support',
    subtitle: 'support@savy.app',
    iconName: 'email',
    colorValue: 0xFF3EFFA8,
    action: 'mailto:support@savy.app',
  ),
  ContactOption(
    title: 'Signaler un bug',
    subtitle: 'Aidez-nous à améliorer Savy',
    iconName: 'bug',
    colorValue: 0xFFFFB340,
    action: 'bug_report',
  ),
  ContactOption(
    title: 'Donner un avis',
    subtitle: 'Notez l\'application',
    iconName: 'star',
    colorValue: 0xFF00D4FF,
    action: 'rate_app',
  ),
];