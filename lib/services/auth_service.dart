import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ══════════════════════════════════════════════════════════
  //  CONNEXION EMAIL — avec vérification obligatoire
  // ══════════════════════════════════════════════════════════
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      // Recharge depuis Firebase pour avoir l'état réel
      await user?.reload();
      final freshUser = _auth.currentUser;

      // Vérifie si l'email est confirmé
      if (freshUser != null && !freshUser.emailVerified) {
        await _auth.signOut(); // force la déconnexion
        return AuthResult.emailNotVerified(
          'Email non vérifié. Consultez votre boîte mail et cliquez sur le lien de confirmation.',
        );
      }

      return AuthResult.success(freshUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapError(e.code));
    } catch (e) {
      return AuthResult.error('Erreur inattendue: ${e.toString()}');
    }
  }

  // ══════════════════════════════════════════════════════════
  //  INSCRIPTION EMAIL — envoie l'email de vérification
  // ══════════════════════════════════════════════════════════
  Future<AuthResult> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());

      // Envoie l'email de vérification
      await credential.user?.sendEmailVerification();

      // Déconnecte — doit vérifier l'email avant de se connecter
      await _auth.signOut();

      return AuthResult.emailSent(
        'Compte créé ! Un email de vérification a été envoyé à $email.\nVérifiez votre boîte mail puis connectez-vous.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapError(e.code));
    } catch (e) {
      return AuthResult.error('Erreur inattendue: ${e.toString()}');
    }
  }

  // ══════════════════════════════════════════════════════════
  //  RENVOYER L'EMAIL DE VÉRIFICATION
  // ══════════════════════════════════════════════════════════
  Future<AuthResult> resendVerificationEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await _auth.signOut();
      return AuthResult.emailSent('Email de vérification renvoyé à $email');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapError(e.code));
    }
  }

  // ══════════════════════════════════════════════════════════
  //  GOOGLE SIGN-IN (pas de vérification email nécessaire)
  // ══════════════════════════════════════════════════════════
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Force l'affichage du sélecteur de compte à chaque fois
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.error('Connexion Google annulée');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapError(e.code));
    } catch (e) {
      return AuthResult.error('Erreur Google Sign-In: ${e.toString()}');
    }
  }
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(null,
          message: 'Email de réinitialisation envoyé à $email');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapError(e.code));
    }
  }

  // ══════════════════════════════════════════════════════════
  //  DÉCONNEXION
  // ══════════════════════════════════════════════════════════
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // ══════════════════════════════════════════════════════════
  //  TRADUCTION ERREURS
  // ══════════════════════════════════════════════════════════
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':         return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':         return 'Mot de passe incorrect';
      case 'invalid-credential':     return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':   return 'Cet email est déjà utilisé';
      case 'weak-password':          return 'Mot de passe trop faible (minimum 6 caractères)';
      case 'invalid-email':          return 'Adresse email invalide';
      case 'user-disabled':          return 'Ce compte a été désactivé';
      case 'too-many-requests':      return 'Trop de tentatives. Réessayez plus tard';
      case 'network-request-failed': return 'Erreur de connexion internet';
      case 'invalid-phone-number':   return 'Numéro de téléphone invalide';
      case 'invalid-verification-code': return 'Code OTP incorrect';
      case 'session-expired':        return 'Code OTP expiré, demandez-en un nouveau';
      default: return 'Erreur ($code)';
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  MODÈLE RÉSULTAT
// ══════════════════════════════════════════════════════════════
class AuthResult {
  final bool isSuccess;
  final bool isEmailNotVerified;
  final bool isEmailSent;
  final User? user;
  final String? errorMessage;
  final String? message;

  const AuthResult._({
    required this.isSuccess,
    this.isEmailNotVerified = false,
    this.isEmailSent = false,
    this.user,
    this.errorMessage,
    this.message,
  });

  factory AuthResult.success(User? user, {String? message}) =>
      AuthResult._(isSuccess: true, user: user, message: message);

  factory AuthResult.error(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);

  factory AuthResult.emailNotVerified(String message) =>
      AuthResult._(isSuccess: false, isEmailNotVerified: true, errorMessage: message);

  factory AuthResult.emailSent(String message) =>
      AuthResult._(isSuccess: false, isEmailSent: true, message: message);
}