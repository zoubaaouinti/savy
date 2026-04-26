// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Savy';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get loading => 'Chargement...';

  @override
  String get retry => 'Réessayer';

  @override
  String get add => 'Ajouter';

  @override
  String get edit => 'Modifier';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get optional => 'Optionnel';

  @override
  String get errorGeneric => 'Une erreur s\'est produite';

  @override
  String get errorNetwork => 'Erreur réseau, veuillez réessayer';

  @override
  String get errorRequired => 'Ce champ est requis';

  @override
  String get errorInvalidEmail => 'Adresse email invalide';

  @override
  String get errorInvalidAmount => 'Montant invalide';

  @override
  String get errorPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get errorWeakPassword => 'Le mot de passe est trop faible';

  @override
  String get langPickerTitle => 'Choisir la langue';

  @override
  String get langFr => 'Français';

  @override
  String get langEn => 'English';

  @override
  String get langAr => 'العربية';

  @override
  String get loginWelcome => 'Bienvenue 👋';

  @override
  String get loginSubtitle => 'Connectez-vous à votre compte';

  @override
  String get loginEmailLabel => 'Adresse email';

  @override
  String get loginEmailHint => 'exemple@email.com';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginPasswordHint => 'Votre mot de passe';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginNoAccount => 'Pas encore de compte ?';

  @override
  String get loginSignupLink => 'S\'inscrire';

  @override
  String get loginOr => 'Ou continuer avec';

  @override
  String get loginGoogle => 'Continuer avec Google';

  @override
  String get loginErrorEmpty => 'Veuillez remplir tous les champs';

  @override
  String get loginErrorInvalidEmail => 'Email invalide';

  @override
  String get loginErrorWrongPassword => 'Mot de passe incorrect';

  @override
  String get loginErrorUserNotFound => 'Aucun compte trouvé avec cet email';

  @override
  String get loginErrorTooManyRequests =>
      'Trop de tentatives, réessayez plus tard';

  @override
  String get loginErrorEmailNotVerified => 'Email non vérifié';

  @override
  String get loginVerifyEmailTitle => 'Vérifiez votre email';

  @override
  String get loginVerifyEmailMessage =>
      'Un email de vérification a été envoyé à';

  @override
  String get loginVerifyEmailResend => 'Renvoyer l\'email';

  @override
  String get loginVerifyEmailDone => 'J\'ai vérifié';

  @override
  String loginVerifyEmailCooldown(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get loginResendSuccess => 'Email de vérification renvoyé !';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre adresse email, nous vous enverrons un lien de réinitialisation.';

  @override
  String get forgotPasswordEmailLabel => 'Adresse email';

  @override
  String get forgotPasswordSend => 'Envoyer le lien';

  @override
  String get forgotPasswordSuccess => 'Email de réinitialisation envoyé !';

  @override
  String get forgotPasswordBack => 'Retour à la connexion';

  @override
  String get signupTitle => 'Créer un compte';

  @override
  String get signupSubtitle => 'Rejoignez Savy et gérez votre épargne';

  @override
  String get signupNameLabel => 'Nom complet';

  @override
  String get signupNameHint => 'Votre nom';

  @override
  String get signupEmailLabel => 'Adresse email';

  @override
  String get signupEmailHint => 'exemple@email.com';

  @override
  String get signupPasswordLabel => 'Mot de passe';

  @override
  String get signupPasswordHint => 'Minimum 8 caractères';

  @override
  String get signupConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get signupConfirmPasswordHint => 'Répétez le mot de passe';

  @override
  String get signupButton => 'S\'inscrire';

  @override
  String get signupAlreadyAccount => 'Déjà un compte ?';

  @override
  String get signupLoginLink => 'Se connecter';

  @override
  String get signupAcceptTerms => 'J\'accepte les';

  @override
  String get signupTerms => 'Conditions d\'utilisation';

  @override
  String get signupAnd => 'et la';

  @override
  String get signupPrivacy => 'Politique de confidentialité';

  @override
  String get signupPasswordStrength => 'Force du mot de passe :';

  @override
  String get signupPasswordWeak => 'Faible';

  @override
  String get signupPasswordMedium => 'Moyen';

  @override
  String get signupPasswordGood => 'Bon';

  @override
  String get signupPasswordExcellent => 'Excellent';

  @override
  String get signupErrorName => 'Veuillez entrer votre nom';

  @override
  String get signupErrorEmail => 'Email invalide';

  @override
  String get signupErrorPassword =>
      'Mot de passe trop court (min. 8 caractères)';

  @override
  String get signupErrorConfirm => 'Les mots de passe ne correspondent pas';

  @override
  String get signupErrorTerms => 'Veuillez accepter les conditions';

  @override
  String get signupErrorEmailInUse => 'Cet email est déjà utilisé';

  @override
  String get signupEmailSentTitle => 'Email envoyé ! 📬';

  @override
  String signupEmailSentMessage(String email) {
    return 'Un email de vérification a été envoyé à $email. Vérifiez votre boîte mail avant de vous connecter.';
  }

  @override
  String get signupEmailSentButton => 'Aller à la connexion';

  @override
  String get signupGoogle => 'Continuer avec Google';

  @override
  String get onboardingNameTitle => 'Quel est votre prénom ?';

  @override
  String get onboardingNameSubtitle =>
      'Bienvenue sur Savy ! Commençons par faire connaissance.';

  @override
  String get onboardingNameHint => 'Entrez votre prénom';

  @override
  String get onboardingNameError => 'Veuillez entrer votre prénom';

  @override
  String get onboardingNameNext => 'Continuer';

  @override
  String get onboardingBalanceTitle => 'Votre solde de départ';

  @override
  String get onboardingBalanceSubtitle =>
      'Quel est votre solde actuel ? Vous pourrez le modifier plus tard.';

  @override
  String get onboardingBalanceHint => '0.00';

  @override
  String get onboardingBalanceCurrency => 'Devise';

  @override
  String get onboardingBalanceFinish => 'Commencer';

  @override
  String get onboardingBalanceError => 'Veuillez entrer un montant valide';

  @override
  String get homeHello => 'Bonjour,';

  @override
  String get homeSubtitle => 'Voici votre tableau de bord';

  @override
  String get homeTotalBalance => 'Solde total';

  @override
  String get homeBudgetUsed => 'de votre budget utilisé';

  @override
  String get homeHealthScore => 'Score santé';

  @override
  String get homeIncome => 'Revenus';

  @override
  String get homeExpenses => 'Dépenses';

  @override
  String get homeMyObjectives => 'Mes objectifs';

  @override
  String get homeRecentTransactions => 'Transactions récentes';

  @override
  String get homeViewAll => 'Voir tout';

  @override
  String get homeNoObjectives => 'Aucun objectif créé';

  @override
  String get homeNoObjectivesHint => 'Créez votre premier objectif d\'épargne';

  @override
  String get homeNoTransactions => 'Aucune transaction';

  @override
  String get homeScoreExcellent => 'Excellent';

  @override
  String get homeScoreGood => 'Bon';

  @override
  String get homeScoreAverage => 'Moyen';

  @override
  String get homeScorePoor => 'À améliorer';

  @override
  String homeObjectiveProgress(String percent) {
    return '$percent% atteint';
  }

  @override
  String get homeExpenseBreakdown => 'Répartition des dépenses';

  @override
  String get homeWeeklyEvolution => 'Évolution hebdomadaire';

  @override
  String get homeAvgProgress => 'Progression moyenne';

  @override
  String get homeKeyIndicators => 'Indicateurs clés';

  @override
  String get homeGaugeUsed => 'utilisé';

  @override
  String homeGaugeRemaining(String amount) {
    return 'Restant : $amount';
  }

  @override
  String get kpiHealthTitle => 'Santé financière';

  @override
  String get kpiHealthTooltipTitle => 'Score de santé financière';

  @override
  String get kpiHealthTooltipBody =>
      'Calculé sur le ratio dépenses / revenus. 100 = budget parfaitement maîtrisé. En dessous de 50, vos dépenses approchent ou dépassent vos revenus.';

  @override
  String get kpiSuggestionsTitle => 'Suggestions';

  @override
  String get kpiSuggestionsSubtitle => 'acceptées';

  @override
  String get kpiSuggestionsTooltipTitle => 'Taux d\'acceptation';

  @override
  String get kpiSuggestionsTooltipBody =>
      'Proportion des objectifs d\'épargne sur lesquels vous avez commencé à épargner. Reflète votre engagement sur les suggestions proposées.';

  @override
  String get kpiObjectivesTitle => 'Objectifs';

  @override
  String get kpiObjectivesSubtitle => 'progression moy.';

  @override
  String get kpiObjectivesTooltipTitle => 'Progression des objectifs';

  @override
  String get kpiObjectivesTooltipBody =>
      'Moyenne de la progression de tous vos objectifs d\'épargne actifs. 100 % signifie que tous vos objectifs sont atteints.';

  @override
  String kpiBudgetOutOf(int total) {
    return 'sur $total';
  }

  @override
  String get kpiBudgetNotExceeded => 'non dépassés';

  @override
  String get kpiBudgetTooltipTitle => 'Dépassements évités';

  @override
  String get kpiBudgetTooltipBody =>
      'Nombre de catégories de budget dont les dépenses restent en dessous de la limite fixée ce mois-ci. Plus le nombre est élevé, mieux c\'est.';

  @override
  String get kpiSessionsOf7 => '/ 7 jours';

  @override
  String get kpiSessionsThisWeek => 'cette semaine';

  @override
  String get kpiSessionsTooltipTitle => 'Sessions actives';

  @override
  String get kpiSessionsTooltipBody =>
      'Nombre de jours différents où vous avez saisi au moins une transaction durant les 7 derniers jours.';

  @override
  String get kpiLastEntry => 'Dernière saisie';

  @override
  String get kpiToday => 'Aujourd\'hui';

  @override
  String get kpiYesterday => 'Hier';

  @override
  String kpiDaysAgo(int days) {
    return 'Il y a $days j.';
  }

  @override
  String get kpiOver7Days => '+7 jours';

  @override
  String get kpiNoEntry => 'Aucune saisie';

  @override
  String get kpiEntryTooltipTitle => 'Saisie régulière';

  @override
  String get kpiEntryTooltipBody =>
      'Vert : vous avez saisi une dépense ou un revenu dans les 7 derniers jours. Orange : aucune saisie récente détectée, pensez à mettre vos finances à jour.';

  @override
  String get kpiSynced => 'Synchronisé';

  @override
  String get kpiOffline => 'Hors ligne';

  @override
  String get kpiSyncTooltipTitle => 'Synchronisation';

  @override
  String get kpiSyncTooltipBody =>
      'Indique si toutes vos données sont synchronisées en temps réel avec Firestore. Le badge devient actif dès que les 5 flux de données sont reçus.';

  @override
  String get kpiDismiss => 'Compris';

  @override
  String get chartNoExpenses => 'Aucune dépense à afficher';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetSubtitle => 'Gérez vos dépenses';

  @override
  String get budgetTabBudget => 'Budget';

  @override
  String get budgetTabRevenues => 'Revenus';

  @override
  String get budgetTotal => 'Budget total';

  @override
  String get budgetSpent => 'Dépensé';

  @override
  String get budgetRemaining => 'Restant';

  @override
  String get budgetAddCategory => 'Ajouter catégorie';

  @override
  String get budgetAddRevenue => 'Ajouter un revenu';

  @override
  String get budgetNoCategoryTitle => 'Aucune catégorie';

  @override
  String get budgetNoCategoryHint =>
      'Appuyez sur + pour ajouter votre premier budget';

  @override
  String get budgetNoRevenueTitle => 'Aucun revenu';

  @override
  String get budgetNoRevenueHint =>
      'Appuyez sur + pour ajouter votre premier revenu';

  @override
  String get budgetDeleteCategory => 'Supprimer la catégorie';

  @override
  String get budgetDeleteRevenue => 'Supprimer le revenu';

  @override
  String get budgetDeleteConfirm => 'Voulez-vous vraiment supprimer';

  @override
  String get budgetDeleteSuccess => 'Supprimé avec succès';

  @override
  String get budgetCategoryBudget => 'Budget';

  @override
  String get budgetCategorySpent => 'Dépensé';

  @override
  String get budgetCategoryRemaining => 'Restant';

  @override
  String get budgetAddTransaction => 'Ajouter une dépense';

  @override
  String get budgetTransactionLabel => 'Libellé';

  @override
  String get budgetTransactionAmount => 'Montant';

  @override
  String get budgetTransactionNote => 'Note';

  @override
  String get budgetTransactionDate => 'Date';

  @override
  String get budgetTransactionAdd => 'Ajouter la dépense';

  @override
  String get budgetRevenueSource => 'Source';

  @override
  String get budgetRevenueAmount => 'Montant';

  @override
  String get budgetRevenueType => 'Type';

  @override
  String get budgetRevenueAdd => 'Ajouter le revenu';

  @override
  String get budgetNewCategory => 'Nouvelle catégorie';

  @override
  String get budgetCategoryName => 'Nom de la catégorie';

  @override
  String get budgetCategoryBudgetLabel => 'Budget (mensuel)';

  @override
  String get budgetCategoryCreate => 'Créer';

  @override
  String get budgetCategoryIcon => 'Icône';

  @override
  String get budgetCategoryColor => 'Couleur';

  @override
  String get budgetOverspent => 'Dépassé';

  @override
  String budgetPercent(String percent) {
    return '$percent%';
  }

  @override
  String get catFood => 'Alimentation';

  @override
  String get catTransport => 'Transport';

  @override
  String get catLeisure => 'Loisirs';

  @override
  String get catAcademic => 'Académique';

  @override
  String get catHealth => 'Santé';

  @override
  String get catOther => 'Autre';

  @override
  String get objectivesTitle => 'Objectifs';

  @override
  String get objectivesSubtitle => 'Vos objectifs d\'épargne';

  @override
  String get objectivesTotalSavings => 'Épargne totale';

  @override
  String get objectivesAdd => 'Nouvel objectif';

  @override
  String get objectivesEmpty => 'Aucun objectif pour l\'instant';

  @override
  String get objectivesEmptyHint => 'Appuyez sur + pour en créer un';

  @override
  String objectivesCount(int count) {
    return '$count objectif';
  }

  @override
  String objectivesCountPlural(int count) {
    return '$count objectifs';
  }

  @override
  String get objectivesDeleteTitle => 'Supprimer l\'objectif';

  @override
  String objectivesDeleteConfirm(String name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String get objectivesAmountToAdd => 'Montant à verser';

  @override
  String get objectivesFeedTitle => 'Alimenter';

  @override
  String get objectivesConfirmPayment => 'Confirmer le versement';

  @override
  String get objectivesMissing => 'Manque :';

  @override
  String get objectivesReached => '% atteint';

  @override
  String get objectivesCompleted => 'Objectif atteint ! 🎉';

  @override
  String objectivesAddedSuccess(String amount, String name) {
    return '+ $amount ajoutés à \"$name\"';
  }

  @override
  String get objectivesName => 'Nom de l\'objectif';

  @override
  String get objectivesNameHint => 'Ex : Voiture, Voyage...';

  @override
  String get objectivesTarget => 'Montant cible';

  @override
  String get objectivesSaved => 'Déjà épargné';

  @override
  String get objectivesDeadline => 'Date limite';

  @override
  String get objectivesPriority => 'Priorité';

  @override
  String get objectivesColor => 'Couleur';

  @override
  String get objectivesIcon => 'Icône';

  @override
  String get objectivesCreate => 'Créer l\'objectif';

  @override
  String get objectivesSortTitle => 'Trier les objectifs';

  @override
  String get objectivesSortSubtitle => 'Choisissez l\'ordre d\'affichage';

  @override
  String get objectivesSortByDate => 'Par date';

  @override
  String get objectivesSortDateDesc => 'Plus récent → plus ancien';

  @override
  String get objectivesSortDateAsc => 'Plus ancien → plus récent';

  @override
  String get objectivesSortDateDescSub => 'Les plus récents en premier';

  @override
  String get objectivesSortDateAscSub => 'Les plus anciens en premier';

  @override
  String get objectivesSortByPriority => 'Par priorité';

  @override
  String get objectivesSortPriorityHighFirst => 'Priorité : haute → basse';

  @override
  String get objectivesSortPriorityLowFirst => 'Priorité : basse → haute';

  @override
  String get objectivesSortPriorityHighFirstSub =>
      'Les plus importants en premier';

  @override
  String get objectivesSortPriorityLowFirstSub =>
      'Les moins importants en premier';

  @override
  String get objectivesSortByProgress => 'Par progression';

  @override
  String get objectivesSortProgressDesc => 'Progression : plus atteint';

  @override
  String get objectivesSortProgressAsc => 'Progression : moins atteint';

  @override
  String get objectivesSortProgressDescSub =>
      'Les plus proches du but en premier';

  @override
  String get objectivesSortProgressAscSub => 'Les moins avancés en premier';

  @override
  String objectivesSuggestion(String amount) {
    return 'Versez $amount/mois pour atteindre votre objectif à temps.';
  }

  @override
  String get objectivesDeadlineLabel => 'Échéance :';

  @override
  String get objectivesPriorityLabel => 'Priorité';

  @override
  String get objectivesAmountError => 'Veuillez saisir un montant';

  @override
  String get objectivesAmountInvalid => 'Montant invalide';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsSubtitle => 'Historique complet';

  @override
  String get transactionsSearch => 'Rechercher une transaction...';

  @override
  String get transactionsAll => 'Tout';

  @override
  String get transactionsExpenses => 'Dépenses';

  @override
  String get transactionsRevenues => 'Revenus';

  @override
  String get transactionsEmpty => 'Aucune transaction trouvée';

  @override
  String transactionsCount(int count) {
    return '$count transaction(s)';
  }

  @override
  String get transactionsDeleteTitle => 'Supprimer la transaction';

  @override
  String get transactionsDeleteConfirm => 'Voulez-vous vraiment supprimer';

  @override
  String get transactionsDeleteSuccess => 'Transaction supprimée';

  @override
  String get transactionsRevenueBadge => 'Revenu';

  @override
  String get transactionsRevenueHint =>
      'Supprimez ce revenu depuis la page Revenus.';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileObjectivesStat => 'objectifs';

  @override
  String get profileTransactionsStat => 'transactions';

  @override
  String get profileHealthScore => 'Score santé';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileCurrency => 'Devise';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileSecurity => 'Sécurité';

  @override
  String get profileHelp => 'Aide & Support';

  @override
  String get profileBackup => 'Sauvegarde';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileLogoutTitle => 'Déconnexion';

  @override
  String get profileLogoutMessage => 'Voulez-vous vous déconnecter ?';

  @override
  String get profileSelectCurrency => 'Choisir une devise';

  @override
  String get profileSearchCurrency => 'Rechercher une devise...';

  @override
  String get profileSelectLanguage => 'Choisir la langue';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get profilePhotoGallery => 'Galerie';

  @override
  String get profilePhotoCamera => 'Caméra';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileName => 'Nom complet';

  @override
  String get editProfileNameHint => 'Votre nom';

  @override
  String get editProfileGender => 'Genre';

  @override
  String get editProfileBirthdate => 'Date de naissance';

  @override
  String get editProfileSave => 'Enregistrer';

  @override
  String get editProfileSuccess => 'Profil mis à jour avec succès';

  @override
  String get editProfileGenderMale => 'Homme';

  @override
  String get editProfileGenderFemale => 'Femme';

  @override
  String get editProfileGenderOther => 'Autre';

  @override
  String get editProfileGenderNotSpecified => 'Non précisé';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountReasonTitle => 'Pourquoi voulez-vous partir ?';

  @override
  String get deleteAccountReason1 => 'Je n\'utilise plus l\'application';

  @override
  String get deleteAccountReason2 =>
      'L\'application ne répond pas à mes besoins';

  @override
  String get deleteAccountReason3 => 'Problèmes de confidentialité';

  @override
  String get deleteAccountReason4 => 'Trop compliquée à utiliser';

  @override
  String get deleteAccountReason5 => 'Autres';

  @override
  String get deleteAccountOtherHint => 'Dites-nous en plus...';

  @override
  String get deleteAccountWarning =>
      '⚠️ Cette action est irréversible. Toutes vos données seront définitivement supprimées.';

  @override
  String get deleteAccountConfirmLabel => 'Tapez \"supprimer\" pour confirmer';

  @override
  String get deleteAccountConfirmHint => 'supprimer';

  @override
  String get deleteAccountConfirmWord => 'supprimer';

  @override
  String get deleteAccountButton => 'Supprimer définitivement';

  @override
  String get deleteAccountErrorReason => 'Veuillez choisir une raison';

  @override
  String get deleteAccountErrorConfirm => 'Tapez \"supprimer\" pour confirmer';

  @override
  String get deleteAccountErrorReauth =>
      'Pour des raisons de sécurité, veuillez vous reconnecter avant de supprimer votre compte.';

  @override
  String get securityTitle => 'Sécurité';

  @override
  String get securityChangePassword => 'Changer le mot de passe';

  @override
  String get securityTwoFactor => 'Authentification à deux facteurs';

  @override
  String get securityActiveSessions => 'Sessions actives';

  @override
  String get helpTitle => 'Aide & Support';

  @override
  String get helpFaq => 'FAQ';

  @override
  String get helpContact => 'Nous contacter';

  @override
  String get helpVersion => 'Version';

  @override
  String get helpScreenTitle => 'Aide & FAQ';

  @override
  String get helpChipAll => 'Tous';

  @override
  String get helpSearchHint => 'Rechercher dans l\'aide...';

  @override
  String get helpSearchNoResults => 'Aucun résultat';

  @override
  String get helpSearchTryOther => 'Essayez d\'autres mots-clés';

  @override
  String get helpContactDialogTitle => 'Contacter le support';

  @override
  String get helpContactSubject => 'Sujet';

  @override
  String get helpContactSubjectHint => 'Ex : Problème avec mon budget...';

  @override
  String get helpContactMessage => 'Message';

  @override
  String get helpContactMessageHint => 'Décrivez votre problème en détail...';

  @override
  String get helpContactFillAll => 'Veuillez remplir tous les champs';

  @override
  String get helpContactSend => 'Envoyer';

  @override
  String get helpContactSuccessTitle => 'Message envoyé !';

  @override
  String get helpContactSuccessBody =>
      'Votre message a bien été envoyé à notre équipe. Nous vous répondrons dans les plus brefs délais.';

  @override
  String get helpContactSuccessBtn => 'Parfait !';

  @override
  String get helpVersionDesc =>
      'Application de gestion budgétaire pour étudiants';

  @override
  String get backupTitle => 'Sauvegarde & Export';

  @override
  String get backupExportPdf => 'Exporter en PDF';

  @override
  String get backupExportCsv => 'Exporter en CSV';

  @override
  String get backupLastBackup => 'Dernière sauvegarde';

  @override
  String get notifBudgetAlert => 'Alerte budget';

  @override
  String notifBudgetAlertBody(String percent, String category) {
    return 'Vous avez atteint $percent% de votre budget $category';
  }

  @override
  String get notifObjectiveComplete => 'Objectif atteint ! 🎉';

  @override
  String notifObjectiveCompleteBody(String name) {
    return 'Félicitations ! Vous avez atteint votre objectif \"$name\".';
  }

  @override
  String get legalTermsTitle => 'Conditions d\'utilisation';

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get splashTagline => 'Gérez votre épargne intelligemment';

  @override
  String get legalScrollHint => 'Faites défiler pour lire';

  @override
  String get legalAcceptTerms => 'J\'accepte les conditions';

  @override
  String get legalAcceptPrivacy => 'J\'accepte la politique';

  @override
  String get navHome => 'Accueil';

  @override
  String get navBudget => 'Budget';

  @override
  String get navObjectives => 'Objectifs';

  @override
  String get navExpenses => 'Dépenses';

  @override
  String get navProfile => 'Profil';

  @override
  String get editProfilePhotoTitle => 'Photo de profil';

  @override
  String get editProfilePhotoGallery => 'Galerie';

  @override
  String get editProfilePhotoCamera => 'Caméra';

  @override
  String get editProfilePhotoDelete => 'Supprimer la photo';

  @override
  String get errorPermissionDenied =>
      'Permission refusée. Activez l\'accès dans les paramètres.';

  @override
  String get errorEmailAlreadyInUse => 'Cet email est déjà utilisé';

  @override
  String get errorRequiresRecentLogin =>
      'Pour des raisons de sécurité, veuillez vous reconnecter.';

  @override
  String editProfileEmailVerificationSent(String email) {
    return 'Un email de vérification a été envoyé à $email. Confirmez avant la prochaine connexion.';
  }

  @override
  String get editProfileSectionPersonal => 'Informations personnelles';

  @override
  String get editProfileEmail => 'Adresse email';

  @override
  String get editProfileSectionAdditional => 'Informations complémentaires';

  @override
  String get editProfileBirthdateHint => 'Sélectionner une date de naissance';

  @override
  String editProfileAge(int age) {
    return '$age ans';
  }

  @override
  String get securityPassStrengthVeryWeak => 'Très faible';

  @override
  String get securityPassStrengthWeak => 'Faible';

  @override
  String get securityPassStrengthMedium => 'Moyen';

  @override
  String get securityPassStrengthStrong => 'Fort';

  @override
  String get securityPassStrengthVeryStrong => 'Très fort';

  @override
  String get securityPasswordChanged => 'Mot de passe modifié avec succès !';

  @override
  String get securityErrorWrongPassword => 'Mot de passe actuel incorrect';

  @override
  String get securityErrorWeakPassword => 'Nouveau mot de passe trop faible';

  @override
  String get securityErrorSessionExpired =>
      'Session expirée, veuillez vous reconnecter';

  @override
  String get securityErrorTooManyRequests =>
      'Trop de tentatives, réessayez plus tard';

  @override
  String get securityTips => 'Conseils de sécurité';

  @override
  String get securityAccountInfo => 'Informations du compte';

  @override
  String get securityGoogleOnlyTitle => 'Connexion Google uniquement';

  @override
  String get securityGoogleOnlyDesc =>
      'Votre compte est lié à Google. La gestion du mot de passe se fait depuis votre compte Google.';

  @override
  String get securityCurrentPassword => 'Mot de passe actuel';

  @override
  String get securityNewPassword => 'Nouveau mot de passe';

  @override
  String get securityErrorPasswordTooShort =>
      'Mot de passe trop court (min. 6 caractères)';

  @override
  String get securityConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get securityErrorPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get securityTipStrongTitle => 'Mot de passe fort';

  @override
  String get securityTipStrongDesc =>
      'Utilisez au moins 8 caractères avec des lettres, chiffres et symboles.';

  @override
  String get securityTipNeverShareTitle => 'Ne partagez jamais';

  @override
  String get securityTipNeverShareDesc =>
      'Ne communiquez jamais votre mot de passe à qui que ce soit.';

  @override
  String get securityTipChangeRegularlyTitle => 'Changez régulièrement';

  @override
  String get securityTipChangeRegularlyDesc =>
      'Renouvelez votre mot de passe tous les 3 à 6 mois.';

  @override
  String get securityTipTrustedDevicesTitle => 'Appareils de confiance';

  @override
  String get securityTipTrustedDevicesDesc =>
      'Déconnectez-vous des appareils que vous ne reconnaissez pas.';

  @override
  String get securityTipVerifiedEmailTitle => 'Email vérifié';

  @override
  String get securityTipVerifiedEmailDesc =>
      'Gardez votre email à jour pour récupérer votre compte.';

  @override
  String get securityEmail => 'Email';

  @override
  String get securityEmailVerified => 'Vérifié';

  @override
  String get securityEmailNotVerified => 'Non vérifié';

  @override
  String get securityLoginMethod => 'Méthode de connexion';

  @override
  String get securityLoginGoogle => 'Google';

  @override
  String get securityLoginEmailPassword => 'Email / Mot de passe';

  @override
  String get securityUid => 'Identifiant';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSectionAccount => 'Compte';

  @override
  String get profileSectionPreferences => 'Préférences';

  @override
  String get profileSectionData => 'Données';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileTermsLabel => 'Conditions d\'utilisation';

  @override
  String get profilePrivacyLabel => 'Politique de confidentialité';

  @override
  String get profileVersion => 'Version 1.0.0';

  @override
  String get profileUserFallback => 'Utilisateur';

  @override
  String get profileCurrencyConvertHint =>
      'Tous les montants seront convertis automatiquement';

  @override
  String get profileNoResults => 'Aucun résultat';

  @override
  String get profileDeleteIrreversible => 'Action irréversible';

  @override
  String get profileDeleteErrorUserNotFound => 'Utilisateur introuvable.';

  @override
  String get profileDeleteErrorSessionExpired =>
      'Reconnectez-vous puis réessayez (session expirée).';

  @override
  String get profileDeleteErrorAuth => 'Erreur d\'authentification';

  @override
  String get profileDeleteErrorGeneric =>
      'Une erreur s\'est produite. Réessayez.';

  @override
  String get backupSaveDataTitle => 'Sauvegarder les données';

  @override
  String get backupFormatExport => 'Format d\'export';

  @override
  String get backupDataToInclude => 'Données à inclure';

  @override
  String get backupIntroText =>
      'Exportez vos données financières en PDF ou CSV. Sélectionnez les sections souhaitées puis visualisez l\'aperçu avant de télécharger.';

  @override
  String get backupPdfLabel => 'Rapport formaté';

  @override
  String get backupCsvLabel => 'Données brutes';

  @override
  String get backupSelected => 'Sélectionné';

  @override
  String get backupFilePreview => 'Aperçu du fichier';

  @override
  String backupSectionsSelected(int count) {
    return '$count section(s) sélectionnée(s)';
  }

  @override
  String get backupPreviewDownloadPdf => 'Aperçu & Télécharger PDF';

  @override
  String get backupSelectAtLeastOne => 'Sélectionnez au moins une section';

  @override
  String get backupCsvSuccess => 'Fichier CSV généré avec succès';

  @override
  String get backupCsvShareText => 'Voici mon export CSV depuis Savy';

  @override
  String get backupPdfPreviewTitle => 'Aperçu PDF';

  @override
  String get backupPdfShareSubject => 'Savy - Rapport financier';

  @override
  String get backupCsvShareSubject => 'Savy - Export CSV';

  @override
  String get exportSectionBudget => 'Budget';

  @override
  String get exportSectionTransactions => 'Transactions';

  @override
  String get exportSectionObjectives => 'Objectifs';

  @override
  String get exportSectionRevenues => 'Revenus';

  @override
  String get legalLastUpdated => 'Dernière mise à jour : 1er janvier 2025';

  @override
  String get legalTermsFooter =>
      'En utilisant Savvy, vous acceptez ces conditions. Pour toute question, contactez-nous à support@savvy.app';

  @override
  String get legalPrivacyFooter =>
      'Pour exercer vos droits ou pour toute question concernant vos données, contactez notre DPO à privacy@savvy.app';

  @override
  String get legalTermsS1Title => '1. Acceptation des conditions';

  @override
  String get legalTermsS1Content =>
      'En accédant à l\'application Savvy ou en l\'utilisant, vous acceptez d\'être lié par ces Conditions d\'utilisation. Si vous n\'acceptez pas l\'intégralité de ces conditions, vous n\'êtes pas autorisé à utiliser nos services. Ces conditions constituent un accord légalement contraignant entre vous et Savvy.';

  @override
  String get legalTermsS2Title => '2. Description du service';

  @override
  String get legalTermsS2Content =>
      'Savvy est une application de gestion financière personnelle qui vous permet de suivre vos dépenses, gérer vos budgets, définir des objectifs d\'épargne et analyser votre santé financière. Nous nous réservons le droit de modifier, suspendre ou interrompre tout ou partie du service à tout moment.';

  @override
  String get legalTermsS3Title => '3. Inscription et compte';

  @override
  String get legalTermsS3Content =>
      'Pour utiliser Savvy, vous devez créer un compte en fournissant des informations exactes et complètes. Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toutes les activités effectuées sous votre compte. Vous devez avoir au moins 18 ans pour créer un compte.';

  @override
  String get legalTermsS4Title => '4. Utilisation acceptable';

  @override
  String get legalTermsS4Content =>
      'Vous acceptez de ne pas utiliser Savvy à des fins illicites, de ne pas tenter d\'accéder sans autorisation à nos systèmes, de ne pas transmettre de virus ou code malveillant, et de ne pas utiliser le service de manière à perturber son fonctionnement normal ou à nuire à d\'autres utilisateurs.';

  @override
  String get legalTermsS5Title => '5. Données financières';

  @override
  String get legalTermsS5Content =>
      'Savvy ne fournit pas de conseils financiers, juridiques ou fiscaux. Les informations présentées dans l\'application sont à titre informatif uniquement. Nous ne sommes pas responsables des décisions financières que vous prenez sur la base des données affichées dans l\'application.';

  @override
  String get legalTermsS6Title => '6. Propriété intellectuelle';

  @override
  String get legalTermsS6Content =>
      'Tous les contenus de Savvy, incluant mais non limité au code, design, logos, textes et graphiques, sont la propriété exclusive de Savvy et sont protégés par les lois sur la propriété intellectuelle. Toute reproduction non autorisée est strictement interdite.';

  @override
  String get legalTermsS7Title => '7. Limitation de responsabilité';

  @override
  String get legalTermsS7Content =>
      'Dans la mesure permise par la loi applicable, Savvy ne saurait être tenu responsable des dommages indirects, accessoires ou consécutifs résultant de l\'utilisation ou de l\'impossibilité d\'utiliser nos services. Notre responsabilité totale ne peut excéder le montant payé pour le service au cours des 12 derniers mois.';

  @override
  String get legalTermsS8Title => '8. Modifications des conditions';

  @override
  String get legalTermsS8Content =>
      'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications entrent en vigueur dès leur publication dans l\'application. Votre utilisation continue du service après la publication constitue votre acceptation des nouvelles conditions. Nous vous notifierons des changements importants par email.';

  @override
  String get legalPrivacyS1Title => '1. Données collectées';

  @override
  String get legalPrivacyS1Content =>
      'Nous collectons les informations que vous nous fournissez directement : nom, adresse email, et données financières que vous saisissez dans l\'application. Nous collectons également automatiquement des données d\'utilisation, des informations sur votre appareil, et des données de navigation pour améliorer nos services.';

  @override
  String get legalPrivacyS2Title => '2. Utilisation des données';

  @override
  String get legalPrivacyS2Content =>
      'Vos données sont utilisées pour fournir et améliorer nos services, personnaliser votre expérience, envoyer des communications liées au service, assurer la sécurité de votre compte, et répondre à vos demandes d\'assistance. Nous n\'utilisons jamais vos données financières à des fins publicitaires.';

  @override
  String get legalPrivacyS3Title => '3. Partage des données';

  @override
  String get legalPrivacyS3Content =>
      'Nous ne vendons jamais vos données personnelles à des tiers. Nous pouvons partager vos informations avec des prestataires de services de confiance qui nous aident à opérer notre plateforme (hébergement, analyse), toujours sous strict accord de confidentialité. Nous divulguerons vos données si la loi l\'exige.';

  @override
  String get legalPrivacyS4Title => '4. Sécurité des données';

  @override
  String get legalPrivacyS4Content =>
      'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles de pointe pour protéger vos données : chiffrement AES-256 au repos, TLS 1.3 en transit, authentification multi-facteurs, et audits de sécurité réguliers. Vos données financières sont traitées avec le plus haut niveau de sécurité.';

  @override
  String get legalPrivacyS5Title => '5. Conservation des données';

  @override
  String get legalPrivacyS5Content =>
      'Nous conservons vos données personnelles aussi longtemps que votre compte est actif ou aussi longtemps que nécessaire pour fournir nos services. Après suppression de votre compte, vos données sont effacées dans un délai de 30 jours, sauf obligation légale de conservation plus longue.';

  @override
  String get legalPrivacyS6Title => '6. Vos droits (RGPD)';

  @override
  String get legalPrivacyS6Content =>
      'Conformément au RGPD, vous disposez du droit d\'accès, de rectification, d\'effacement, de portabilité et d\'opposition au traitement de vos données. Vous pouvez exercer ces droits depuis les paramètres de l\'application ou en nous contactant. Vous avez également le droit d\'introduire une réclamation auprès de la CNIL.';

  @override
  String get legalPrivacyS7Title => '7. Cookies et traceurs';

  @override
  String get legalPrivacyS7Content =>
      'Nous utilisons des cookies essentiels pour le fonctionnement de l\'application et des cookies analytiques anonymisés pour comprendre comment vous utilisez nos services. Vous pouvez gérer vos préférences de cookies dans les paramètres de l\'application. Aucun cookie publicitaire n\'est utilisé.';

  @override
  String get legalPrivacyS8Title => '8. Transferts internationaux';

  @override
  String get legalPrivacyS8Content =>
      'Vos données peuvent être transférées et traitées dans des pays autres que votre pays de résidence. Dans ce cas, nous nous assurons que des garanties appropriées sont en place, notamment via des clauses contractuelles types approuvées par la Commission européenne, pour protéger vos données.';

  @override
  String get notifSettingsTitle => 'Paramètres de notifications';

  @override
  String get notifSettingsEnableAll => 'Activer toutes les notifications';

  @override
  String get notifSettingsBudgetAlert => 'Alertes budget';

  @override
  String get notifSettingsBudgetAlertDesc =>
      'Soyez notifié quand vous atteignez 90 % de votre budget';

  @override
  String get notifSettingsGoalReminder => 'Rappels d\'objectifs';

  @override
  String get notifSettingsGoalReminderDesc =>
      'Rappels quand l\'échéance de votre objectif approche';

  @override
  String get notifSettingsGoalCompletion => 'Objectifs atteints';

  @override
  String get notifSettingsGoalCompletionDesc =>
      'Célébrez quand vous atteignez un objectif d\'épargne';

  @override
  String get notifSettingsSavingSuggestion => 'Suggestions d\'épargne';

  @override
  String get notifSettingsSavingSuggestionDesc =>
      'Conseils personnalisés pour vous aider à épargner davantage';

  @override
  String get notifSettingsSectionSecurity => 'Sécurité';

  @override
  String get notifSettingsSecurityAlert => 'Alertes de sécurité';

  @override
  String get notifSettingsSecurityAlertDesc =>
      'Recevoir une notification push lors d\'un changement de mot de passe';

  @override
  String get notificationsPageTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'Aucune notification pour l\'instant';

  @override
  String get notificationsEmptyDesc =>
      'Vos alertes et rappels apparaîtront ici';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsToday => 'Aujourd\'hui';

  @override
  String get notificationsEarlier => 'Précédemment';

  @override
  String get notificationsDeleteTitle => 'Supprimer la notification';

  @override
  String get notificationsDeleteDesc =>
      'Cette notification sera définitivement supprimée.';

  @override
  String get notificationsDeleteAllTitle => 'Effacer toutes les notifications';

  @override
  String get notificationsDeleteAllDesc =>
      'Toutes vos notifications seront définitivement supprimées.';

  @override
  String get notificationsCancel => 'Annuler';

  @override
  String get notificationsDelete => 'Supprimer';

  @override
  String get notificationsDeleteAll => 'Tout effacer';

  @override
  String get notifTimeJustNow => 'À l\'instant';

  @override
  String notifTimeMinutes(int n) {
    return 'Il y a $n min';
  }

  @override
  String notifTimeHours(int n) {
    return 'Il y a $n h';
  }

  @override
  String notifTimeDays(int n) {
    return 'Il y a $n j';
  }

  @override
  String get homeSpendingBreakdown => 'Répartition des dépenses';

  @override
  String get homeWeeklyTrend => 'Évolution hebdomadaire';
}
