import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Savy'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @optional.
  ///
  /// In fr, this message translates to:
  /// **'Optionnel'**
  String get optional;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau, veuillez réessayer'**
  String get errorNetwork;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide'**
  String get errorInvalidAmount;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get errorPasswordMismatch;

  /// No description provided for @errorWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est trop faible'**
  String get errorWeakPassword;

  /// No description provided for @langPickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get langPickerTitle;

  /// No description provided for @langFr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get langFr;

  /// No description provided for @langEn.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langAr.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get langAr;

  /// No description provided for @loginWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue 👋'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'exemple@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get loginNoAccount;

  /// No description provided for @loginSignupLink.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get loginSignupLink;

  /// No description provided for @loginOr.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get loginOr;

  /// No description provided for @loginGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get loginGoogle;

  /// No description provided for @loginErrorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir tous les champs'**
  String get loginErrorEmpty;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte trouvé avec cet email'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives, réessayez plus tard'**
  String get loginErrorTooManyRequests;

  /// No description provided for @loginErrorEmailNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Email non vérifié'**
  String get loginErrorEmailNotVerified;

  /// No description provided for @loginVerifyEmailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email'**
  String get loginVerifyEmailTitle;

  /// No description provided for @loginVerifyEmailMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un email de vérification a été envoyé à'**
  String get loginVerifyEmailMessage;

  /// No description provided for @loginVerifyEmailResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer l\'email'**
  String get loginVerifyEmailResend;

  /// No description provided for @loginVerifyEmailDone.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai vérifié'**
  String get loginVerifyEmailDone;

  /// No description provided for @loginVerifyEmailCooldown.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds}s'**
  String loginVerifyEmailCooldown(int seconds);

  /// No description provided for @loginResendSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Email de vérification renvoyé !'**
  String get loginResendSuccess;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre adresse email, nous vous enverrons un lien de réinitialisation.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Email de réinitialisation envoyé !'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get forgotPasswordBack;

  /// No description provided for @signupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Savy et gérez votre épargne'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get signupNameLabel;

  /// No description provided for @signupNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get signupNameHint;

  /// No description provided for @signupEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get signupEmailLabel;

  /// No description provided for @signupEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'exemple@email.com'**
  String get signupEmailHint;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 8 caractères'**
  String get signupPasswordHint;

  /// No description provided for @signupConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get signupConfirmPasswordLabel;

  /// No description provided for @signupConfirmPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Répétez le mot de passe'**
  String get signupConfirmPasswordHint;

  /// No description provided for @signupButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signupButton;

  /// No description provided for @signupAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get signupAlreadyAccount;

  /// No description provided for @signupLoginLink.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signupLoginLink;

  /// No description provided for @signupAcceptTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les'**
  String get signupAcceptTerms;

  /// No description provided for @signupTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get signupTerms;

  /// No description provided for @signupAnd.
  ///
  /// In fr, this message translates to:
  /// **'et la'**
  String get signupAnd;

  /// No description provided for @signupPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get signupPrivacy;

  /// No description provided for @signupPasswordStrength.
  ///
  /// In fr, this message translates to:
  /// **'Force du mot de passe :'**
  String get signupPasswordStrength;

  /// No description provided for @signupPasswordWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get signupPasswordWeak;

  /// No description provided for @signupPasswordMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get signupPasswordMedium;

  /// No description provided for @signupPasswordGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get signupPasswordGood;

  /// No description provided for @signupPasswordExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get signupPasswordExcellent;

  /// No description provided for @signupErrorName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get signupErrorName;

  /// No description provided for @signupErrorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get signupErrorEmail;

  /// No description provided for @signupErrorPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court (min. 8 caractères)'**
  String get signupErrorPassword;

  /// No description provided for @signupErrorConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get signupErrorConfirm;

  /// No description provided for @signupErrorTerms.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez accepter les conditions'**
  String get signupErrorTerms;

  /// No description provided for @signupErrorEmailInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé'**
  String get signupErrorEmailInUse;

  /// No description provided for @signupEmailSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé ! 📬'**
  String get signupEmailSentTitle;

  /// No description provided for @signupEmailSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un email de vérification a été envoyé à {email}. Vérifiez votre boîte mail avant de vous connecter.'**
  String signupEmailSentMessage(String email);

  /// No description provided for @signupEmailSentButton.
  ///
  /// In fr, this message translates to:
  /// **'Aller à la connexion'**
  String get signupEmailSentButton;

  /// No description provided for @signupGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get signupGoogle;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quel est votre prénom ?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Savy ! Commençons par faire connaissance.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre prénom'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNameError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre prénom'**
  String get onboardingNameError;

  /// No description provided for @onboardingNameNext.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onboardingNameNext;

  /// No description provided for @onboardingBalanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde de départ'**
  String get onboardingBalanceTitle;

  /// No description provided for @onboardingBalanceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Quel est votre solde actuel ? Vous pourrez le modifier plus tard.'**
  String get onboardingBalanceSubtitle;

  /// No description provided for @onboardingBalanceHint.
  ///
  /// In fr, this message translates to:
  /// **'0.00'**
  String get onboardingBalanceHint;

  /// No description provided for @onboardingBalanceCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get onboardingBalanceCurrency;

  /// No description provided for @onboardingBalanceFinish.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingBalanceFinish;

  /// No description provided for @onboardingBalanceError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un montant valide'**
  String get onboardingBalanceError;

  /// No description provided for @homeHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour,'**
  String get homeHello;

  /// No description provided for @homeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Voici votre tableau de bord'**
  String get homeSubtitle;

  /// No description provided for @homeTotalBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde total'**
  String get homeTotalBalance;

  /// No description provided for @homeBudgetUsed.
  ///
  /// In fr, this message translates to:
  /// **'de votre budget utilisé'**
  String get homeBudgetUsed;

  /// No description provided for @homeHealthScore.
  ///
  /// In fr, this message translates to:
  /// **'Score santé'**
  String get homeHealthScore;

  /// No description provided for @homeIncome.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get homeIncome;

  /// No description provided for @homeExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get homeExpenses;

  /// No description provided for @homeMyObjectives.
  ///
  /// In fr, this message translates to:
  /// **'Mes objectifs'**
  String get homeMyObjectives;

  /// No description provided for @homeRecentTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions récentes'**
  String get homeRecentTransactions;

  /// No description provided for @homeViewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get homeViewAll;

  /// No description provided for @homeNoObjectives.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif créé'**
  String get homeNoObjectives;

  /// No description provided for @homeNoObjectivesHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier objectif d\'épargne'**
  String get homeNoObjectivesHint;

  /// No description provided for @homeNoTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction'**
  String get homeNoTransactions;

  /// No description provided for @homeScoreExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get homeScoreExcellent;

  /// No description provided for @homeScoreGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get homeScoreGood;

  /// No description provided for @homeScoreAverage.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get homeScoreAverage;

  /// No description provided for @homeScorePoor.
  ///
  /// In fr, this message translates to:
  /// **'À améliorer'**
  String get homeScorePoor;

  /// No description provided for @homeObjectiveProgress.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% atteint'**
  String homeObjectiveProgress(String percent);

  /// No description provided for @homeExpenseBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des dépenses'**
  String get homeExpenseBreakdown;

  /// No description provided for @homeWeeklyEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution hebdomadaire'**
  String get homeWeeklyEvolution;

  /// No description provided for @homeAvgProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression moyenne'**
  String get homeAvgProgress;

  /// No description provided for @homeKeyIndicators.
  ///
  /// In fr, this message translates to:
  /// **'Indicateurs clés'**
  String get homeKeyIndicators;

  /// No description provided for @homeGaugeUsed.
  ///
  /// In fr, this message translates to:
  /// **'utilisé'**
  String get homeGaugeUsed;

  /// No description provided for @homeGaugeRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Restant : {amount}'**
  String homeGaugeRemaining(String amount);

  /// No description provided for @kpiHealthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Santé financière'**
  String get kpiHealthTitle;

  /// No description provided for @kpiHealthTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Score de santé financière'**
  String get kpiHealthTooltipTitle;

  /// No description provided for @kpiHealthTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Calculé sur le ratio dépenses / revenus. 100 = budget parfaitement maîtrisé. En dessous de 50, vos dépenses approchent ou dépassent vos revenus.'**
  String get kpiHealthTooltipBody;

  /// No description provided for @kpiSuggestionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suggestions'**
  String get kpiSuggestionsTitle;

  /// No description provided for @kpiSuggestionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'acceptées'**
  String get kpiSuggestionsSubtitle;

  /// No description provided for @kpiSuggestionsTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'acceptation'**
  String get kpiSuggestionsTooltipTitle;

  /// No description provided for @kpiSuggestionsTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Proportion des objectifs d\'épargne sur lesquels vous avez commencé à épargner. Reflète votre engagement sur les suggestions proposées.'**
  String get kpiSuggestionsTooltipBody;

  /// No description provided for @kpiObjectivesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get kpiObjectivesTitle;

  /// No description provided for @kpiObjectivesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'progression moy.'**
  String get kpiObjectivesSubtitle;

  /// No description provided for @kpiObjectivesTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Progression des objectifs'**
  String get kpiObjectivesTooltipTitle;

  /// No description provided for @kpiObjectivesTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne de la progression de tous vos objectifs d\'épargne actifs. 100 % signifie que tous vos objectifs sont atteints.'**
  String get kpiObjectivesTooltipBody;

  /// No description provided for @kpiBudgetOutOf.
  ///
  /// In fr, this message translates to:
  /// **'sur {total}'**
  String kpiBudgetOutOf(int total);

  /// No description provided for @kpiBudgetNotExceeded.
  ///
  /// In fr, this message translates to:
  /// **'non dépassés'**
  String get kpiBudgetNotExceeded;

  /// No description provided for @kpiBudgetTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dépassements évités'**
  String get kpiBudgetTooltipTitle;

  /// No description provided for @kpiBudgetTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de catégories de budget dont les dépenses restent en dessous de la limite fixée ce mois-ci. Plus le nombre est élevé, mieux c\'est.'**
  String get kpiBudgetTooltipBody;

  /// No description provided for @kpiSessionsOf7.
  ///
  /// In fr, this message translates to:
  /// **'/ 7 jours'**
  String get kpiSessionsOf7;

  /// No description provided for @kpiSessionsThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'cette semaine'**
  String get kpiSessionsThisWeek;

  /// No description provided for @kpiSessionsTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sessions actives'**
  String get kpiSessionsTooltipTitle;

  /// No description provided for @kpiSessionsTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de jours différents où vous avez saisi au moins une transaction durant les 7 derniers jours.'**
  String get kpiSessionsTooltipBody;

  /// No description provided for @kpiLastEntry.
  ///
  /// In fr, this message translates to:
  /// **'Dernière saisie'**
  String get kpiLastEntry;

  /// No description provided for @kpiToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get kpiToday;

  /// No description provided for @kpiYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get kpiYesterday;

  /// No description provided for @kpiDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} j.'**
  String kpiDaysAgo(int days);

  /// No description provided for @kpiOver7Days.
  ///
  /// In fr, this message translates to:
  /// **'+7 jours'**
  String get kpiOver7Days;

  /// No description provided for @kpiNoEntry.
  ///
  /// In fr, this message translates to:
  /// **'Aucune saisie'**
  String get kpiNoEntry;

  /// No description provided for @kpiEntryTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisie régulière'**
  String get kpiEntryTooltipTitle;

  /// No description provided for @kpiEntryTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Vert : vous avez saisi une dépense ou un revenu dans les 7 derniers jours. Orange : aucune saisie récente détectée, pensez à mettre vos finances à jour.'**
  String get kpiEntryTooltipBody;

  /// No description provided for @kpiSynced.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé'**
  String get kpiSynced;

  /// No description provided for @kpiOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get kpiOffline;

  /// No description provided for @kpiSyncTooltipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get kpiSyncTooltipTitle;

  /// No description provided for @kpiSyncTooltipBody.
  ///
  /// In fr, this message translates to:
  /// **'Indique si toutes vos données sont synchronisées en temps réel avec Firestore. Le badge devient actif dès que les 5 flux de données sont reçus.'**
  String get kpiSyncTooltipBody;

  /// No description provided for @kpiDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get kpiDismiss;

  /// No description provided for @chartNoExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense à afficher'**
  String get chartNoExpenses;

  /// No description provided for @budgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos dépenses'**
  String get budgetSubtitle;

  /// No description provided for @budgetTabBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get budgetTabBudget;

  /// No description provided for @budgetTabRevenues.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get budgetTabRevenues;

  /// No description provided for @budgetTabExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get budgetTabExpenses;

  /// No description provided for @budgetTotal.
  ///
  /// In fr, this message translates to:
  /// **'Budget total'**
  String get budgetTotal;

  /// No description provided for @budgetSpent.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Restant'**
  String get budgetRemaining;

  /// No description provided for @budgetAddCategory.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter catégorie'**
  String get budgetAddCategory;

  /// No description provided for @budgetAddRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un revenu'**
  String get budgetAddRevenue;

  /// No description provided for @budgetNoCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie'**
  String get budgetNoCategoryTitle;

  /// No description provided for @budgetNoCategoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur + pour ajouter votre premier budget'**
  String get budgetNoCategoryHint;

  /// No description provided for @budgetNoRevenueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun revenu'**
  String get budgetNoRevenueTitle;

  /// No description provided for @budgetNoRevenueHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur + pour ajouter votre premier revenu'**
  String get budgetNoRevenueHint;

  /// No description provided for @budgetDeleteCategory.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la catégorie'**
  String get budgetDeleteCategory;

  /// No description provided for @budgetDeleteRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le revenu'**
  String get budgetDeleteRevenue;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer'**
  String get budgetDeleteConfirm;

  /// No description provided for @budgetDeleteSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé avec succès'**
  String get budgetDeleteSuccess;

  /// No description provided for @budgetCategoryBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get budgetCategoryBudget;

  /// No description provided for @budgetCategorySpent.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé'**
  String get budgetCategorySpent;

  /// No description provided for @budgetCategoryRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Restant'**
  String get budgetCategoryRemaining;

  /// No description provided for @budgetAddTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une dépense'**
  String get budgetAddTransaction;

  /// No description provided for @budgetTransactionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get budgetTransactionLabel;

  /// No description provided for @budgetTransactionAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get budgetTransactionAmount;

  /// No description provided for @budgetTransactionNote.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get budgetTransactionNote;

  /// No description provided for @budgetTransactionDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get budgetTransactionDate;

  /// No description provided for @budgetTransactionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la dépense'**
  String get budgetTransactionAdd;

  /// No description provided for @budgetRevenueSource.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get budgetRevenueSource;

  /// No description provided for @budgetRevenueAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get budgetRevenueAmount;

  /// No description provided for @budgetRevenueType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get budgetRevenueType;

  /// No description provided for @budgetRevenueAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le revenu'**
  String get budgetRevenueAdd;

  /// No description provided for @budgetNewCategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get budgetNewCategory;

  /// No description provided for @budgetCategoryName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get budgetCategoryName;

  /// No description provided for @budgetCategoryBudgetLabel.
  ///
  /// In fr, this message translates to:
  /// **'Budget (mensuel)'**
  String get budgetCategoryBudgetLabel;

  /// No description provided for @budgetCategoryCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get budgetCategoryCreate;

  /// No description provided for @budgetCategoryIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get budgetCategoryIcon;

  /// No description provided for @budgetCategoryColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get budgetCategoryColor;

  /// No description provided for @budgetOverspent.
  ///
  /// In fr, this message translates to:
  /// **'Dépassé'**
  String get budgetOverspent;

  /// No description provided for @budgetPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent}%'**
  String budgetPercent(String percent);

  /// No description provided for @catFood.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catLeisure.
  ///
  /// In fr, this message translates to:
  /// **'Loisirs'**
  String get catLeisure;

  /// No description provided for @catAcademic.
  ///
  /// In fr, this message translates to:
  /// **'Académique'**
  String get catAcademic;

  /// No description provided for @catHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get catHealth;

  /// No description provided for @catOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get catOther;

  /// No description provided for @objectivesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get objectivesTitle;

  /// No description provided for @objectivesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos objectifs d\'épargne'**
  String get objectivesSubtitle;

  /// No description provided for @objectivesTotalSavings.
  ///
  /// In fr, this message translates to:
  /// **'Épargne totale'**
  String get objectivesTotalSavings;

  /// No description provided for @objectivesAdd.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel objectif'**
  String get objectivesAdd;

  /// No description provided for @objectivesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif pour l\'instant'**
  String get objectivesEmpty;

  /// No description provided for @objectivesEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur + pour en créer un'**
  String get objectivesEmptyHint;

  /// No description provided for @objectivesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} objectif'**
  String objectivesCount(int count);

  /// No description provided for @objectivesCountPlural.
  ///
  /// In fr, this message translates to:
  /// **'{count} objectifs'**
  String objectivesCountPlural(int count);

  /// No description provided for @objectivesDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'objectif'**
  String get objectivesDeleteTitle;

  /// No description provided for @objectivesDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer \"{name}\" ?'**
  String objectivesDeleteConfirm(String name);

  /// No description provided for @objectivesAmountToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Montant à verser'**
  String get objectivesAmountToAdd;

  /// No description provided for @objectivesFeedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alimenter'**
  String get objectivesFeedTitle;

  /// No description provided for @objectivesConfirmPayment.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le versement'**
  String get objectivesConfirmPayment;

  /// No description provided for @objectivesMissing.
  ///
  /// In fr, this message translates to:
  /// **'Manque :'**
  String get objectivesMissing;

  /// No description provided for @objectivesReached.
  ///
  /// In fr, this message translates to:
  /// **'% atteint'**
  String get objectivesReached;

  /// No description provided for @objectivesCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint ! 🎉'**
  String get objectivesCompleted;

  /// No description provided for @objectivesAddedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'+ {amount} ajoutés à \"{name}\"'**
  String objectivesAddedSuccess(String amount, String name);

  /// No description provided for @objectivesName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'objectif'**
  String get objectivesName;

  /// No description provided for @objectivesNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Voiture, Voyage...'**
  String get objectivesNameHint;

  /// No description provided for @objectivesTarget.
  ///
  /// In fr, this message translates to:
  /// **'Montant cible'**
  String get objectivesTarget;

  /// No description provided for @objectivesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Déjà épargné'**
  String get objectivesSaved;

  /// No description provided for @objectivesDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get objectivesDeadline;

  /// No description provided for @objectivesPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get objectivesPriority;

  /// No description provided for @objectivesColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get objectivesColor;

  /// No description provided for @objectivesIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get objectivesIcon;

  /// No description provided for @objectivesCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'objectif'**
  String get objectivesCreate;

  /// No description provided for @objectivesSortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trier les objectifs'**
  String get objectivesSortTitle;

  /// No description provided for @objectivesSortSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez l\'ordre d\'affichage'**
  String get objectivesSortSubtitle;

  /// No description provided for @objectivesSortByDate.
  ///
  /// In fr, this message translates to:
  /// **'Par date'**
  String get objectivesSortByDate;

  /// No description provided for @objectivesSortDateDesc.
  ///
  /// In fr, this message translates to:
  /// **'Plus récent → plus ancien'**
  String get objectivesSortDateDesc;

  /// No description provided for @objectivesSortDateAsc.
  ///
  /// In fr, this message translates to:
  /// **'Plus ancien → plus récent'**
  String get objectivesSortDateAsc;

  /// No description provided for @objectivesSortDateDescSub.
  ///
  /// In fr, this message translates to:
  /// **'Les plus récents en premier'**
  String get objectivesSortDateDescSub;

  /// No description provided for @objectivesSortDateAscSub.
  ///
  /// In fr, this message translates to:
  /// **'Les plus anciens en premier'**
  String get objectivesSortDateAscSub;

  /// No description provided for @objectivesSortByPriority.
  ///
  /// In fr, this message translates to:
  /// **'Par priorité'**
  String get objectivesSortByPriority;

  /// No description provided for @objectivesSortPriorityHighFirst.
  ///
  /// In fr, this message translates to:
  /// **'Priorité : haute → basse'**
  String get objectivesSortPriorityHighFirst;

  /// No description provided for @objectivesSortPriorityLowFirst.
  ///
  /// In fr, this message translates to:
  /// **'Priorité : basse → haute'**
  String get objectivesSortPriorityLowFirst;

  /// No description provided for @objectivesSortPriorityHighFirstSub.
  ///
  /// In fr, this message translates to:
  /// **'Les plus importants en premier'**
  String get objectivesSortPriorityHighFirstSub;

  /// No description provided for @objectivesSortPriorityLowFirstSub.
  ///
  /// In fr, this message translates to:
  /// **'Les moins importants en premier'**
  String get objectivesSortPriorityLowFirstSub;

  /// No description provided for @objectivesSortByProgress.
  ///
  /// In fr, this message translates to:
  /// **'Par progression'**
  String get objectivesSortByProgress;

  /// No description provided for @objectivesSortProgressDesc.
  ///
  /// In fr, this message translates to:
  /// **'Progression : plus atteint'**
  String get objectivesSortProgressDesc;

  /// No description provided for @objectivesSortProgressAsc.
  ///
  /// In fr, this message translates to:
  /// **'Progression : moins atteint'**
  String get objectivesSortProgressAsc;

  /// No description provided for @objectivesSortProgressDescSub.
  ///
  /// In fr, this message translates to:
  /// **'Les plus proches du but en premier'**
  String get objectivesSortProgressDescSub;

  /// No description provided for @objectivesSortProgressAscSub.
  ///
  /// In fr, this message translates to:
  /// **'Les moins avancés en premier'**
  String get objectivesSortProgressAscSub;

  /// No description provided for @objectivesSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'Versez {amount}/mois pour atteindre votre objectif à temps.'**
  String objectivesSuggestion(String amount);

  /// No description provided for @objectivesDeadlineLabel.
  ///
  /// In fr, this message translates to:
  /// **'Échéance :'**
  String get objectivesDeadlineLabel;

  /// No description provided for @objectivesPriorityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get objectivesPriorityLabel;

  /// No description provided for @objectivesAmountError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un montant'**
  String get objectivesAmountError;

  /// No description provided for @objectivesAmountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide'**
  String get objectivesAmountInvalid;

  /// No description provided for @transactionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @transactionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique complet'**
  String get transactionsSubtitle;

  /// No description provided for @transactionsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une transaction...'**
  String get transactionsSearch;

  /// No description provided for @transactionsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get transactionsAll;

  /// No description provided for @transactionsExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get transactionsExpenses;

  /// No description provided for @transactionsRevenues.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get transactionsRevenues;

  /// No description provided for @transactionsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction trouvée'**
  String get transactionsEmpty;

  /// No description provided for @transactionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} transaction(s)'**
  String transactionsCount(int count);

  /// No description provided for @transactionsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la transaction'**
  String get transactionsDeleteTitle;

  /// No description provided for @transactionsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer'**
  String get transactionsDeleteConfirm;

  /// No description provided for @transactionsDeleteSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Transaction supprimée'**
  String get transactionsDeleteSuccess;

  /// No description provided for @transactionsRevenueBadge.
  ///
  /// In fr, this message translates to:
  /// **'Revenu'**
  String get transactionsRevenueBadge;

  /// No description provided for @transactionsRevenueHint.
  ///
  /// In fr, this message translates to:
  /// **'Supprimez ce revenu depuis la page Revenus.'**
  String get transactionsRevenueHint;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileTitle;

  /// No description provided for @profileObjectivesStat.
  ///
  /// In fr, this message translates to:
  /// **'objectifs'**
  String get profileObjectivesStat;

  /// No description provided for @profileTransactionsStat.
  ///
  /// In fr, this message translates to:
  /// **'transactions'**
  String get profileTransactionsStat;

  /// No description provided for @profileHealthScore.
  ///
  /// In fr, this message translates to:
  /// **'Score santé'**
  String get profileHealthScore;

  /// No description provided for @profileSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get profileSettings;

  /// No description provided for @profileCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get profileCurrency;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get profileSecurity;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get profileHelp;

  /// No description provided for @profileBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get profileBackup;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get profileDeleteAccount;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vous déconnecter ?'**
  String get profileLogoutMessage;

  /// No description provided for @profileSelectCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une devise'**
  String get profileSelectCurrency;

  /// No description provided for @profileSearchCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une devise...'**
  String get profileSearchCurrency;

  /// No description provided for @profileSelectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get profileSelectLanguage;

  /// No description provided for @profilePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get profilePhoto;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get profilePhotoCamera;

  /// No description provided for @editProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get editProfileName;

  /// No description provided for @editProfileNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get editProfileNameHint;

  /// No description provided for @editProfileGender.
  ///
  /// In fr, this message translates to:
  /// **'Genre'**
  String get editProfileGender;

  /// No description provided for @editProfileBirthdate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get editProfileBirthdate;

  /// No description provided for @editProfileSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get editProfileSave;

  /// No description provided for @editProfileSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès'**
  String get editProfileSuccess;

  /// No description provided for @editProfileGenderMale.
  ///
  /// In fr, this message translates to:
  /// **'Homme'**
  String get editProfileGenderMale;

  /// No description provided for @editProfileGenderFemale.
  ///
  /// In fr, this message translates to:
  /// **'Femme'**
  String get editProfileGenderFemale;

  /// No description provided for @editProfileGenderOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get editProfileGenderOther;

  /// No description provided for @editProfileGenderNotSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non précisé'**
  String get editProfileGenderNotSpecified;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountReasonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi voulez-vous partir ?'**
  String get deleteAccountReasonTitle;

  /// No description provided for @deleteAccountReason1.
  ///
  /// In fr, this message translates to:
  /// **'Je n\'utilise plus l\'application'**
  String get deleteAccountReason1;

  /// No description provided for @deleteAccountReason2.
  ///
  /// In fr, this message translates to:
  /// **'L\'application ne répond pas à mes besoins'**
  String get deleteAccountReason2;

  /// No description provided for @deleteAccountReason3.
  ///
  /// In fr, this message translates to:
  /// **'Problèmes de confidentialité'**
  String get deleteAccountReason3;

  /// No description provided for @deleteAccountReason4.
  ///
  /// In fr, this message translates to:
  /// **'Trop compliquée à utiliser'**
  String get deleteAccountReason4;

  /// No description provided for @deleteAccountReason5.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get deleteAccountReason5;

  /// No description provided for @deleteAccountOtherHint.
  ///
  /// In fr, this message translates to:
  /// **'Dites-nous en plus...'**
  String get deleteAccountOtherHint;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Cette action est irréversible. Toutes vos données seront définitivement supprimées.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tapez \"supprimer\" pour confirmer'**
  String get deleteAccountConfirmLabel;

  /// No description provided for @deleteAccountConfirmHint.
  ///
  /// In fr, this message translates to:
  /// **'supprimer'**
  String get deleteAccountConfirmHint;

  /// No description provided for @deleteAccountConfirmWord.
  ///
  /// In fr, this message translates to:
  /// **'supprimer'**
  String get deleteAccountConfirmWord;

  /// No description provided for @deleteAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountErrorReason.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez choisir une raison'**
  String get deleteAccountErrorReason;

  /// No description provided for @deleteAccountErrorConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tapez \"supprimer\" pour confirmer'**
  String get deleteAccountErrorConfirm;

  /// No description provided for @deleteAccountErrorReauth.
  ///
  /// In fr, this message translates to:
  /// **'Pour des raisons de sécurité, veuillez vous reconnecter avant de supprimer votre compte.'**
  String get deleteAccountErrorReauth;

  /// No description provided for @securityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get securityTitle;

  /// No description provided for @securityChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get securityChangePassword;

  /// No description provided for @securityTwoFactor.
  ///
  /// In fr, this message translates to:
  /// **'Authentification à deux facteurs'**
  String get securityTwoFactor;

  /// No description provided for @securityActiveSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions actives'**
  String get securityActiveSessions;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get helpTitle;

  /// No description provided for @helpFaq.
  ///
  /// In fr, this message translates to:
  /// **'FAQ'**
  String get helpFaq;

  /// No description provided for @helpContact.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get helpContact;

  /// No description provided for @helpVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get helpVersion;

  /// No description provided for @helpScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide & FAQ'**
  String get helpScreenTitle;

  /// No description provided for @helpChipAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get helpChipAll;

  /// No description provided for @helpSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans l\'aide...'**
  String get helpSearchHint;

  /// No description provided for @helpSearchNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get helpSearchNoResults;

  /// No description provided for @helpSearchTryOther.
  ///
  /// In fr, this message translates to:
  /// **'Essayez d\'autres mots-clés'**
  String get helpSearchTryOther;

  /// No description provided for @helpContactDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support'**
  String get helpContactDialogTitle;

  /// No description provided for @helpContactSubject.
  ///
  /// In fr, this message translates to:
  /// **'Sujet'**
  String get helpContactSubject;

  /// No description provided for @helpContactSubjectHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Problème avec mon budget...'**
  String get helpContactSubjectHint;

  /// No description provided for @helpContactMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get helpContactMessage;

  /// No description provided for @helpContactMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre problème en détail...'**
  String get helpContactMessageHint;

  /// No description provided for @helpContactFillAll.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir tous les champs'**
  String get helpContactFillAll;

  /// No description provided for @helpContactSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get helpContactSend;

  /// No description provided for @helpContactSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Message envoyé !'**
  String get helpContactSuccessTitle;

  /// No description provided for @helpContactSuccessBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre message a bien été envoyé à notre équipe. Nous vous répondrons dans les plus brefs délais.'**
  String get helpContactSuccessBody;

  /// No description provided for @helpContactSuccessBtn.
  ///
  /// In fr, this message translates to:
  /// **'Parfait !'**
  String get helpContactSuccessBtn;

  /// No description provided for @helpVersionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Application de gestion budgétaire pour étudiants'**
  String get helpVersionDesc;

  /// No description provided for @backupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde & Export'**
  String get backupTitle;

  /// No description provided for @backupExportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get backupExportPdf;

  /// No description provided for @backupExportCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get backupExportCsv;

  /// No description provided for @backupLastBackup.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sauvegarde'**
  String get backupLastBackup;

  /// No description provided for @notifBudgetAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alerte budget'**
  String get notifBudgetAlert;

  /// No description provided for @notifBudgetAlertBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez atteint {percent}% de votre budget {category}'**
  String notifBudgetAlertBody(String percent, String category);

  /// No description provided for @notifObjectiveComplete.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint ! 🎉'**
  String get notifObjectiveComplete;

  /// No description provided for @notifObjectiveCompleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Félicitations ! Vous avez atteint votre objectif \"{name}\".'**
  String notifObjectiveCompleteBody(String name);

  /// No description provided for @legalTermsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get legalPrivacyTitle;

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre épargne intelligemment'**
  String get splashTagline;

  /// No description provided for @legalScrollHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites défiler pour lire'**
  String get legalScrollHint;

  /// No description provided for @legalAcceptTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les conditions'**
  String get legalAcceptTerms;

  /// No description provided for @legalAcceptPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte la politique'**
  String get legalAcceptPrivacy;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navObjectives.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get navObjectives;

  /// No description provided for @navExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get navExpenses;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @editProfilePhotoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get editProfilePhotoTitle;

  /// No description provided for @editProfilePhotoGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get editProfilePhotoGallery;

  /// No description provided for @editProfilePhotoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get editProfilePhotoCamera;

  /// No description provided for @editProfilePhotoDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get editProfilePhotoDelete;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission refusée. Activez l\'accès dans les paramètres.'**
  String get errorPermissionDenied;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorRequiresRecentLogin.
  ///
  /// In fr, this message translates to:
  /// **'Pour des raisons de sécurité, veuillez vous reconnecter.'**
  String get errorRequiresRecentLogin;

  /// No description provided for @editProfileEmailVerificationSent.
  ///
  /// In fr, this message translates to:
  /// **'Un email de vérification a été envoyé à {email}. Confirmez avant la prochaine connexion.'**
  String editProfileEmailVerificationSent(String email);

  /// No description provided for @editProfileSectionPersonal.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get editProfileSectionPersonal;

  /// No description provided for @editProfileEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get editProfileEmail;

  /// No description provided for @editProfileSectionAdditional.
  ///
  /// In fr, this message translates to:
  /// **'Informations complémentaires'**
  String get editProfileSectionAdditional;

  /// No description provided for @editProfileBirthdateHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date de naissance'**
  String get editProfileBirthdateHint;

  /// No description provided for @editProfileAge.
  ///
  /// In fr, this message translates to:
  /// **'{age} ans'**
  String editProfileAge(int age);

  /// No description provided for @securityPassStrengthVeryWeak.
  ///
  /// In fr, this message translates to:
  /// **'Très faible'**
  String get securityPassStrengthVeryWeak;

  /// No description provided for @securityPassStrengthWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get securityPassStrengthWeak;

  /// No description provided for @securityPassStrengthMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get securityPassStrengthMedium;

  /// No description provided for @securityPassStrengthStrong.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get securityPassStrengthStrong;

  /// No description provided for @securityPassStrengthVeryStrong.
  ///
  /// In fr, this message translates to:
  /// **'Très fort'**
  String get securityPassStrengthVeryStrong;

  /// No description provided for @securityPasswordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès !'**
  String get securityPasswordChanged;

  /// No description provided for @securityErrorWrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel incorrect'**
  String get securityErrorWrongPassword;

  /// No description provided for @securityErrorWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe trop faible'**
  String get securityErrorWeakPassword;

  /// No description provided for @securityErrorSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée, veuillez vous reconnecter'**
  String get securityErrorSessionExpired;

  /// No description provided for @securityErrorTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives, réessayez plus tard'**
  String get securityErrorTooManyRequests;

  /// No description provided for @securityTips.
  ///
  /// In fr, this message translates to:
  /// **'Conseils de sécurité'**
  String get securityTips;

  /// No description provided for @securityAccountInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte'**
  String get securityAccountInfo;

  /// No description provided for @securityGoogleOnlyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google uniquement'**
  String get securityGoogleOnlyTitle;

  /// No description provided for @securityGoogleOnlyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte est lié à Google. La gestion du mot de passe se fait depuis votre compte Google.'**
  String get securityGoogleOnlyDesc;

  /// No description provided for @securityCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get securityCurrentPassword;

  /// No description provided for @securityNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get securityNewPassword;

  /// No description provided for @securityErrorPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court (min. 6 caractères)'**
  String get securityErrorPasswordTooShort;

  /// No description provided for @securityConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get securityConfirmPassword;

  /// No description provided for @securityErrorPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get securityErrorPasswordMismatch;

  /// No description provided for @securityTipStrongTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe fort'**
  String get securityTipStrongTitle;

  /// No description provided for @securityTipStrongDesc.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez au moins 8 caractères avec des lettres, chiffres et symboles.'**
  String get securityTipStrongDesc;

  /// No description provided for @securityTipNeverShareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ne partagez jamais'**
  String get securityTipNeverShareTitle;

  /// No description provided for @securityTipNeverShareDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ne communiquez jamais votre mot de passe à qui que ce soit.'**
  String get securityTipNeverShareDesc;

  /// No description provided for @securityTipChangeRegularlyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changez régulièrement'**
  String get securityTipChangeRegularlyTitle;

  /// No description provided for @securityTipChangeRegularlyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Renouvelez votre mot de passe tous les 3 à 6 mois.'**
  String get securityTipChangeRegularlyDesc;

  /// No description provided for @securityTipTrustedDevicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appareils de confiance'**
  String get securityTipTrustedDevicesTitle;

  /// No description provided for @securityTipTrustedDevicesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Déconnectez-vous des appareils que vous ne reconnaissez pas.'**
  String get securityTipTrustedDevicesDesc;

  /// No description provided for @securityTipVerifiedEmailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Email vérifié'**
  String get securityTipVerifiedEmailTitle;

  /// No description provided for @securityTipVerifiedEmailDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gardez votre email à jour pour récupérer votre compte.'**
  String get securityTipVerifiedEmailDesc;

  /// No description provided for @securityEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get securityEmail;

  /// No description provided for @securityEmailVerified.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get securityEmailVerified;

  /// No description provided for @securityEmailNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Non vérifié'**
  String get securityEmailNotVerified;

  /// No description provided for @securityLoginMethod.
  ///
  /// In fr, this message translates to:
  /// **'Méthode de connexion'**
  String get securityLoginMethod;

  /// No description provided for @securityLoginGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Google'**
  String get securityLoginGoogle;

  /// No description provided for @securityLoginEmailPassword.
  ///
  /// In fr, this message translates to:
  /// **'Email / Mot de passe'**
  String get securityLoginEmailPassword;

  /// No description provided for @securityUid.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get securityUid;

  /// No description provided for @profileEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEditProfile;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileSectionAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get profileSectionData;

  /// No description provided for @profileSectionSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileTermsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get profileTermsLabel;

  /// No description provided for @profilePrivacyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get profilePrivacyLabel;

  /// No description provided for @profileVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0'**
  String get profileVersion;

  /// No description provided for @profileUserFallback.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get profileUserFallback;

  /// No description provided for @profileCurrencyConvertHint.
  ///
  /// In fr, this message translates to:
  /// **'Tous les montants seront convertis automatiquement'**
  String get profileCurrencyConvertHint;

  /// No description provided for @profileNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get profileNoResults;

  /// No description provided for @profileDeleteIrreversible.
  ///
  /// In fr, this message translates to:
  /// **'Action irréversible'**
  String get profileDeleteIrreversible;

  /// No description provided for @profileDeleteErrorUserNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur introuvable.'**
  String get profileDeleteErrorUserNotFound;

  /// No description provided for @profileDeleteErrorSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Reconnectez-vous puis réessayez (session expirée).'**
  String get profileDeleteErrorSessionExpired;

  /// No description provided for @profileDeleteErrorAuth.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'authentification'**
  String get profileDeleteErrorAuth;

  /// No description provided for @profileDeleteErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite. Réessayez.'**
  String get profileDeleteErrorGeneric;

  /// No description provided for @backupSaveDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder les données'**
  String get backupSaveDataTitle;

  /// No description provided for @backupFormatExport.
  ///
  /// In fr, this message translates to:
  /// **'Format d\'export'**
  String get backupFormatExport;

  /// No description provided for @backupDataToInclude.
  ///
  /// In fr, this message translates to:
  /// **'Données à inclure'**
  String get backupDataToInclude;

  /// No description provided for @backupIntroText.
  ///
  /// In fr, this message translates to:
  /// **'Exportez vos données financières en PDF ou CSV. Sélectionnez les sections souhaitées puis visualisez l\'aperçu avant de télécharger.'**
  String get backupIntroText;

  /// No description provided for @backupPdfLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rapport formaté'**
  String get backupPdfLabel;

  /// No description provided for @backupCsvLabel.
  ///
  /// In fr, this message translates to:
  /// **'Données brutes'**
  String get backupCsvLabel;

  /// No description provided for @backupSelected.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionné'**
  String get backupSelected;

  /// No description provided for @backupFilePreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du fichier'**
  String get backupFilePreview;

  /// No description provided for @backupSectionsSelected.
  ///
  /// In fr, this message translates to:
  /// **'{count} section(s) sélectionnée(s)'**
  String backupSectionsSelected(int count);

  /// No description provided for @backupPreviewDownloadPdf.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu & Télécharger PDF'**
  String get backupPreviewDownloadPdf;

  /// No description provided for @backupSelectAtLeastOne.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins une section'**
  String get backupSelectAtLeastOne;

  /// No description provided for @backupCsvSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Fichier CSV généré avec succès'**
  String get backupCsvSuccess;

  /// No description provided for @backupCsvShareText.
  ///
  /// In fr, this message translates to:
  /// **'Voici mon export CSV depuis Savy'**
  String get backupCsvShareText;

  /// No description provided for @backupPdfPreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu PDF'**
  String get backupPdfPreviewTitle;

  /// No description provided for @backupPdfShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Savy - Rapport financier'**
  String get backupPdfShareSubject;

  /// No description provided for @backupCsvShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Savy - Export CSV'**
  String get backupCsvShareSubject;

  /// No description provided for @exportSectionBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get exportSectionBudget;

  /// No description provided for @exportSectionTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get exportSectionTransactions;

  /// No description provided for @exportSectionObjectives.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get exportSectionObjectives;

  /// No description provided for @exportSectionRevenues.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get exportSectionRevenues;

  /// No description provided for @legalLastUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : 1er janvier 2025'**
  String get legalLastUpdated;

  /// No description provided for @legalTermsFooter.
  ///
  /// In fr, this message translates to:
  /// **'En utilisant Savvy, vous acceptez ces conditions. Pour toute question, contactez-nous à support@savvy.app'**
  String get legalTermsFooter;

  /// No description provided for @legalPrivacyFooter.
  ///
  /// In fr, this message translates to:
  /// **'Pour exercer vos droits ou pour toute question concernant vos données, contactez notre DPO à privacy@savvy.app'**
  String get legalPrivacyFooter;

  /// No description provided for @legalTermsS1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Acceptation des conditions'**
  String get legalTermsS1Title;

  /// No description provided for @legalTermsS1Content.
  ///
  /// In fr, this message translates to:
  /// **'En accédant à l\'application Savvy ou en l\'utilisant, vous acceptez d\'être lié par ces Conditions d\'utilisation. Si vous n\'acceptez pas l\'intégralité de ces conditions, vous n\'êtes pas autorisé à utiliser nos services. Ces conditions constituent un accord légalement contraignant entre vous et Savvy.'**
  String get legalTermsS1Content;

  /// No description provided for @legalTermsS2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Description du service'**
  String get legalTermsS2Title;

  /// No description provided for @legalTermsS2Content.
  ///
  /// In fr, this message translates to:
  /// **'Savvy est une application de gestion financière personnelle qui vous permet de suivre vos dépenses, gérer vos budgets, définir des objectifs d\'épargne et analyser votre santé financière. Nous nous réservons le droit de modifier, suspendre ou interrompre tout ou partie du service à tout moment.'**
  String get legalTermsS2Content;

  /// No description provided for @legalTermsS3Title.
  ///
  /// In fr, this message translates to:
  /// **'3. Inscription et compte'**
  String get legalTermsS3Title;

  /// No description provided for @legalTermsS3Content.
  ///
  /// In fr, this message translates to:
  /// **'Pour utiliser Savvy, vous devez créer un compte en fournissant des informations exactes et complètes. Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toutes les activités effectuées sous votre compte. Vous devez avoir au moins 18 ans pour créer un compte.'**
  String get legalTermsS3Content;

  /// No description provided for @legalTermsS4Title.
  ///
  /// In fr, this message translates to:
  /// **'4. Utilisation acceptable'**
  String get legalTermsS4Title;

  /// No description provided for @legalTermsS4Content.
  ///
  /// In fr, this message translates to:
  /// **'Vous acceptez de ne pas utiliser Savvy à des fins illicites, de ne pas tenter d\'accéder sans autorisation à nos systèmes, de ne pas transmettre de virus ou code malveillant, et de ne pas utiliser le service de manière à perturber son fonctionnement normal ou à nuire à d\'autres utilisateurs.'**
  String get legalTermsS4Content;

  /// No description provided for @legalTermsS5Title.
  ///
  /// In fr, this message translates to:
  /// **'5. Données financières'**
  String get legalTermsS5Title;

  /// No description provided for @legalTermsS5Content.
  ///
  /// In fr, this message translates to:
  /// **'Savvy ne fournit pas de conseils financiers, juridiques ou fiscaux. Les informations présentées dans l\'application sont à titre informatif uniquement. Nous ne sommes pas responsables des décisions financières que vous prenez sur la base des données affichées dans l\'application.'**
  String get legalTermsS5Content;

  /// No description provided for @legalTermsS6Title.
  ///
  /// In fr, this message translates to:
  /// **'6. Propriété intellectuelle'**
  String get legalTermsS6Title;

  /// No description provided for @legalTermsS6Content.
  ///
  /// In fr, this message translates to:
  /// **'Tous les contenus de Savvy, incluant mais non limité au code, design, logos, textes et graphiques, sont la propriété exclusive de Savvy et sont protégés par les lois sur la propriété intellectuelle. Toute reproduction non autorisée est strictement interdite.'**
  String get legalTermsS6Content;

  /// No description provided for @legalTermsS7Title.
  ///
  /// In fr, this message translates to:
  /// **'7. Limitation de responsabilité'**
  String get legalTermsS7Title;

  /// No description provided for @legalTermsS7Content.
  ///
  /// In fr, this message translates to:
  /// **'Dans la mesure permise par la loi applicable, Savvy ne saurait être tenu responsable des dommages indirects, accessoires ou consécutifs résultant de l\'utilisation ou de l\'impossibilité d\'utiliser nos services. Notre responsabilité totale ne peut excéder le montant payé pour le service au cours des 12 derniers mois.'**
  String get legalTermsS7Content;

  /// No description provided for @legalTermsS8Title.
  ///
  /// In fr, this message translates to:
  /// **'8. Modifications des conditions'**
  String get legalTermsS8Title;

  /// No description provided for @legalTermsS8Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications entrent en vigueur dès leur publication dans l\'application. Votre utilisation continue du service après la publication constitue votre acceptation des nouvelles conditions. Nous vous notifierons des changements importants par email.'**
  String get legalTermsS8Content;

  /// No description provided for @legalPrivacyS1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Données collectées'**
  String get legalPrivacyS1Title;

  /// No description provided for @legalPrivacyS1Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous collectons les informations que vous nous fournissez directement : nom, adresse email, et données financières que vous saisissez dans l\'application. Nous collectons également automatiquement des données d\'utilisation, des informations sur votre appareil, et des données de navigation pour améliorer nos services.'**
  String get legalPrivacyS1Content;

  /// No description provided for @legalPrivacyS2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Utilisation des données'**
  String get legalPrivacyS2Title;

  /// No description provided for @legalPrivacyS2Content.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont utilisées pour fournir et améliorer nos services, personnaliser votre expérience, envoyer des communications liées au service, assurer la sécurité de votre compte, et répondre à vos demandes d\'assistance. Nous n\'utilisons jamais vos données financières à des fins publicitaires.'**
  String get legalPrivacyS2Content;

  /// No description provided for @legalPrivacyS3Title.
  ///
  /// In fr, this message translates to:
  /// **'3. Partage des données'**
  String get legalPrivacyS3Title;

  /// No description provided for @legalPrivacyS3Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous ne vendons jamais vos données personnelles à des tiers. Nous pouvons partager vos informations avec des prestataires de services de confiance qui nous aident à opérer notre plateforme (hébergement, analyse), toujours sous strict accord de confidentialité. Nous divulguerons vos données si la loi l\'exige.'**
  String get legalPrivacyS3Content;

  /// No description provided for @legalPrivacyS4Title.
  ///
  /// In fr, this message translates to:
  /// **'4. Sécurité des données'**
  String get legalPrivacyS4Title;

  /// No description provided for @legalPrivacyS4Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles de pointe pour protéger vos données : chiffrement AES-256 au repos, TLS 1.3 en transit, authentification multi-facteurs, et audits de sécurité réguliers. Vos données financières sont traitées avec le plus haut niveau de sécurité.'**
  String get legalPrivacyS4Content;

  /// No description provided for @legalPrivacyS5Title.
  ///
  /// In fr, this message translates to:
  /// **'5. Conservation des données'**
  String get legalPrivacyS5Title;

  /// No description provided for @legalPrivacyS5Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous conservons vos données personnelles aussi longtemps que votre compte est actif ou aussi longtemps que nécessaire pour fournir nos services. Après suppression de votre compte, vos données sont effacées dans un délai de 30 jours, sauf obligation légale de conservation plus longue.'**
  String get legalPrivacyS5Content;

  /// No description provided for @legalPrivacyS6Title.
  ///
  /// In fr, this message translates to:
  /// **'6. Vos droits (RGPD)'**
  String get legalPrivacyS6Title;

  /// No description provided for @legalPrivacyS6Content.
  ///
  /// In fr, this message translates to:
  /// **'Conformément au RGPD, vous disposez du droit d\'accès, de rectification, d\'effacement, de portabilité et d\'opposition au traitement de vos données. Vous pouvez exercer ces droits depuis les paramètres de l\'application ou en nous contactant. Vous avez également le droit d\'introduire une réclamation auprès de la CNIL.'**
  String get legalPrivacyS6Content;

  /// No description provided for @legalPrivacyS7Title.
  ///
  /// In fr, this message translates to:
  /// **'7. Cookies et traceurs'**
  String get legalPrivacyS7Title;

  /// No description provided for @legalPrivacyS7Content.
  ///
  /// In fr, this message translates to:
  /// **'Nous utilisons des cookies essentiels pour le fonctionnement de l\'application et des cookies analytiques anonymisés pour comprendre comment vous utilisez nos services. Vous pouvez gérer vos préférences de cookies dans les paramètres de l\'application. Aucun cookie publicitaire n\'est utilisé.'**
  String get legalPrivacyS7Content;

  /// No description provided for @legalPrivacyS8Title.
  ///
  /// In fr, this message translates to:
  /// **'8. Transferts internationaux'**
  String get legalPrivacyS8Title;

  /// No description provided for @legalPrivacyS8Content.
  ///
  /// In fr, this message translates to:
  /// **'Vos données peuvent être transférées et traitées dans des pays autres que votre pays de résidence. Dans ce cas, nous nous assurons que des garanties appropriées sont en place, notamment via des clauses contractuelles types approuvées par la Commission européenne, pour protéger vos données.'**
  String get legalPrivacyS8Content;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de notifications'**
  String get notifSettingsTitle;

  /// No description provided for @notifSettingsEnableAll.
  ///
  /// In fr, this message translates to:
  /// **'Activer toutes les notifications'**
  String get notifSettingsEnableAll;

  /// No description provided for @notifSettingsBudgetAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alertes budget'**
  String get notifSettingsBudgetAlert;

  /// No description provided for @notifSettingsBudgetAlertDesc.
  ///
  /// In fr, this message translates to:
  /// **'Soyez notifié quand vous atteignez 90 % de votre budget'**
  String get notifSettingsBudgetAlertDesc;

  /// No description provided for @notifSettingsGoalReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappels d\'objectifs'**
  String get notifSettingsGoalReminder;

  /// No description provided for @notifSettingsGoalReminderDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rappels quand l\'échéance de votre objectif approche'**
  String get notifSettingsGoalReminderDesc;

  /// No description provided for @notifSettingsGoalCompletion.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs atteints'**
  String get notifSettingsGoalCompletion;

  /// No description provided for @notifSettingsGoalCompletionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Célébrez quand vous atteignez un objectif d\'épargne'**
  String get notifSettingsGoalCompletionDesc;

  /// No description provided for @notifSettingsSavingSuggestion.
  ///
  /// In fr, this message translates to:
  /// **'Suggestions d\'épargne'**
  String get notifSettingsSavingSuggestion;

  /// No description provided for @notifSettingsSavingSuggestionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Conseils personnalisés pour vous aider à épargner davantage'**
  String get notifSettingsSavingSuggestionDesc;

  /// No description provided for @notifSettingsSectionSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get notifSettingsSectionSecurity;

  /// No description provided for @notifSettingsSecurityAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de sécurité'**
  String get notifSettingsSecurityAlert;

  /// No description provided for @notifSettingsSecurityAlertDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir une notification push lors d\'un changement de mot de passe'**
  String get notifSettingsSecurityAlertDesc;

  /// No description provided for @notificationsPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsPageTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification pour l\'instant'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vos alertes et rappels apparaîtront ici'**
  String get notificationsEmptyDesc;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get notificationsToday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In fr, this message translates to:
  /// **'Précédemment'**
  String get notificationsEarlier;

  /// No description provided for @notificationsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la notification'**
  String get notificationsDeleteTitle;

  /// No description provided for @notificationsDeleteDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cette notification sera définitivement supprimée.'**
  String get notificationsDeleteDesc;

  /// No description provided for @notificationsDeleteAllTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les notifications'**
  String get notificationsDeleteAllTitle;

  /// No description provided for @notificationsDeleteAllDesc.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos notifications seront définitivement supprimées.'**
  String get notificationsDeleteAllDesc;

  /// No description provided for @notificationsCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get notificationsCancel;

  /// No description provided for @notificationsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get notificationsDelete;

  /// No description provided for @notificationsDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get notificationsDeleteAll;

  /// No description provided for @notifTimeJustNow.
  ///
  /// In fr, this message translates to:
  /// **'À l\'instant'**
  String get notifTimeJustNow;

  /// No description provided for @notifTimeMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {n} min'**
  String notifTimeMinutes(int n);

  /// No description provided for @notifTimeHours.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {n} h'**
  String notifTimeHours(int n);

  /// No description provided for @notifTimeDays.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {n} j'**
  String notifTimeDays(int n);

  /// No description provided for @homeSpendingBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des dépenses'**
  String get homeSpendingBreakdown;

  /// No description provided for @homeWeeklyTrend.
  ///
  /// In fr, this message translates to:
  /// **'Évolution hebdomadaire'**
  String get homeWeeklyTrend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
