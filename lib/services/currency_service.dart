import 'dart:convert';
import 'package:http/http.dart' as http;

// ══════════════════════════════════════════════════════════════
//  SERVICE – CurrencyService
//  Taux de change depuis TND via API gratuite (sans clé)
//  Source: cdn.jsdelivr.net/@fawazahmed0/currency-api
// ══════════════════════════════════════════════════════════════

class CurrencyService {
  static const _primaryUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/tnd.json';
  static const _fallbackUrl =
      'https://latest.currency-api.pages.dev/v1/currencies/tnd.json';

  // Retourne un Map<CODE, taux_depuis_TND>
  Future<Map<String, double>> fetchRatesFromTND() async {
    for (final url in [_primaryUrl, _fallbackUrl]) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final rates = data['tnd'] as Map<String, dynamic>;
          return rates.map(
            (key, value) => MapEntry(
              key.toUpperCase(),
              (value as num).toDouble(),
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }
    return {};
  }
}
