import 'dart:convert';
import 'package:http/http.dart' as http;

// ══════════════════════════════════════════════════════════════
//  SAVVY – EMAILJS SERVICE
//  lib/services/emailjs_service.dart
//
//  ⚠️  Remplace les valeurs ci-dessous par les tiennes :
//      SERVICE_ID  → EmailJS > Email Services > ton service
//      TEMPLATE_ID → EmailJS > Email Templates > ton template
//      PUBLIC_KEY  → EmailJS > Account > General > Public Key
// ══════════════════════════════════════════════════════════════

class EmailJSService {
  static const String _serviceId  = 'service_athn72g';   // ← remplace
  static const String _templateId = 'template_ynmeynt';  // ← remplace
  static const String _publicKey  = 'Gcvp38JAYCaVmyV9t';    // ← remplace

  static const String _apiUrl =
      'https://api.emailjs.com/api/v1.0/email/send';

  /// Envoie un email via EmailJS
  /// [userName]  → nom de l'utilisateur qui envoie
  /// [userEmail] → email de l'utilisateur (pour répondre)
  /// [subject]   → sujet du message
  /// [message]   → contenu du message
  static Future<EmailResult> sendEmail({
    required String userName,
    required String userEmail,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id':  _serviceId,
          'template_id': _templateId,
          'user_id':     _publicKey,
          'template_params': {
            'user_name':  userName,
            'user_email': userEmail,
            'subject':    subject,
            'message':    message,
            'to_email':   'zouba.aouinti@gmail.com',
          },
        }),
      );

      if (response.statusCode == 200) {
        return EmailResult.success();
      } else {
        return EmailResult.error(
            'Erreur serveur (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      return EmailResult.error('Erreur de connexion: ${e.toString()}');
    }
  }
}

// ── Résultat d'envoi ──────────────────────────────────────────
class EmailResult {
  final bool isSuccess;
  final String? errorMessage;

  const EmailResult._({required this.isSuccess, this.errorMessage});

  factory EmailResult.success() => const EmailResult._(isSuccess: true);
  factory EmailResult.error(String msg) =>
      EmailResult._(isSuccess: false, errorMessage: msg);
}