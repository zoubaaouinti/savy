// ══════════════════════════════════════════════════════════════
//  MODEL – CurrencyInfo
// ══════════════════════════════════════════════════════════════

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  static const defaultCurrency = CurrencyInfo(
    code: 'TND',
    name: 'Dinar tunisien',
    symbol: 'TND',
    flag: '🇹🇳',
  );

  static CurrencyInfo? findByCode(String code) {
    for (final c in allCurrencies) {
      if (c.code == code) return c;
    }
    return null;
  }

  String format(double amount) {
    final noDecimal = {'JPY', 'KRW', 'VND', 'IDR', 'HUF', 'UGX', 'TZS', 'RWF', 'BIF', 'GNF'};
    final decimals = noDecimal.contains(code) ? 0 : 2;
    return '${amount.toStringAsFixed(decimals)} $symbol';
  }

  static const allCurrencies = <CurrencyInfo>[
    // ── Maghreb & Moyen-Orient ─────────────────────────────
    CurrencyInfo(code: 'TND', name: 'Dinar tunisien',       symbol: 'TND', flag: '🇹🇳'),
    CurrencyInfo(code: 'DZD', name: 'Dinar algérien',       symbol: 'DZD', flag: '🇩🇿'),
    CurrencyInfo(code: 'MAD', name: 'Dirham marocain',      symbol: 'MAD', flag: '🇲🇦'),
    CurrencyInfo(code: 'LYD', name: 'Dinar libyen',         symbol: 'LYD', flag: '🇱🇾'),
    CurrencyInfo(code: 'EGP', name: 'Livre égyptienne',     symbol: 'EGP', flag: '🇪🇬'),
    CurrencyInfo(code: 'SAR', name: 'Riyal saoudien',       symbol: 'SAR', flag: '🇸🇦'),
    CurrencyInfo(code: 'AED', name: 'Dirham émirati',       symbol: 'AED', flag: '🇦🇪'),
    CurrencyInfo(code: 'QAR', name: 'Riyal qatari',         symbol: 'QAR', flag: '🇶🇦'),
    CurrencyInfo(code: 'KWD', name: 'Dinar koweïtien',      symbol: 'KWD', flag: '🇰🇼'),
    CurrencyInfo(code: 'BHD', name: 'Dinar bahreïni',       symbol: 'BHD', flag: '🇧🇭'),
    CurrencyInfo(code: 'OMR', name: 'Rial omanais',         symbol: 'OMR', flag: '🇴🇲'),
    CurrencyInfo(code: 'JOD', name: 'Dinar jordanien',      symbol: 'JOD', flag: '🇯🇴'),
    CurrencyInfo(code: 'LBP', name: 'Livre libanaise',      symbol: 'LBP', flag: '🇱🇧'),
    CurrencyInfo(code: 'IQD', name: 'Dinar irakien',        symbol: 'IQD', flag: '🇮🇶'),
    CurrencyInfo(code: 'ILS', name: 'Shekel israélien',     symbol: '₪',   flag: '🇮🇱'),
    CurrencyInfo(code: 'IRR', name: 'Rial iranien',         symbol: 'IRR', flag: '🇮🇷'),
    CurrencyInfo(code: 'YER', name: 'Rial yéménite',        symbol: 'YER', flag: '🇾🇪'),
    // ── Europe ────────────────────────────────────────────
    CurrencyInfo(code: 'EUR', name: 'Euro',                  symbol: '€',   flag: '🇪🇺'),
    CurrencyInfo(code: 'GBP', name: 'Livre sterling',        symbol: '£',   flag: '🇬🇧'),
    CurrencyInfo(code: 'CHF', name: 'Franc suisse',          symbol: 'CHF', flag: '🇨🇭'),
    CurrencyInfo(code: 'NOK', name: 'Couronne norvégienne',  symbol: 'NOK', flag: '🇳🇴'),
    CurrencyInfo(code: 'SEK', name: 'Couronne suédoise',     symbol: 'SEK', flag: '🇸🇪'),
    CurrencyInfo(code: 'DKK', name: 'Couronne danoise',      symbol: 'DKK', flag: '🇩🇰'),
    CurrencyInfo(code: 'PLN', name: 'Złoty polonais',        symbol: 'PLN', flag: '🇵🇱'),
    CurrencyInfo(code: 'CZK', name: 'Couronne tchèque',      symbol: 'CZK', flag: '🇨🇿'),
    CurrencyInfo(code: 'HUF', name: 'Forint hongrois',       symbol: 'HUF', flag: '🇭🇺'),
    CurrencyInfo(code: 'RON', name: 'Leu roumain',           symbol: 'RON', flag: '🇷🇴'),
    CurrencyInfo(code: 'HRK', name: 'Kuna croate',           symbol: 'HRK', flag: '🇭🇷'),
    CurrencyInfo(code: 'TRY', name: 'Livre turque',          symbol: '₺',   flag: '🇹🇷'),
    CurrencyInfo(code: 'RUB', name: 'Rouble russe',          symbol: '₽',   flag: '🇷🇺'),
    CurrencyInfo(code: 'UAH', name: 'Hryvnia ukrainienne',   symbol: '₴',   flag: '🇺🇦'),
    // ── Amériques ─────────────────────────────────────────
    CurrencyInfo(code: 'USD', name: 'Dollar américain',      symbol: '\$',  flag: '🇺🇸'),
    CurrencyInfo(code: 'CAD', name: 'Dollar canadien',       symbol: 'CA\$',flag: '🇨🇦'),
    CurrencyInfo(code: 'MXN', name: 'Peso mexicain',         symbol: 'MXN', flag: '🇲🇽'),
    CurrencyInfo(code: 'BRL', name: 'Réal brésilien',        symbol: 'R\$', flag: '🇧🇷'),
    CurrencyInfo(code: 'ARS', name: 'Peso argentin',         symbol: 'ARS', flag: '🇦🇷'),
    CurrencyInfo(code: 'CLP', name: 'Peso chilien',          symbol: 'CLP', flag: '🇨🇱'),
    CurrencyInfo(code: 'COP', name: 'Peso colombien',        symbol: 'COP', flag: '🇨🇴'),
    CurrencyInfo(code: 'PEN', name: 'Sol péruvien',          symbol: 'PEN', flag: '🇵🇪'),
    // ── Asie-Pacifique ────────────────────────────────────
    CurrencyInfo(code: 'JPY', name: 'Yen japonais',          symbol: '¥',   flag: '🇯🇵'),
    CurrencyInfo(code: 'CNY', name: 'Yuan chinois',          symbol: '¥',   flag: '🇨🇳'),
    CurrencyInfo(code: 'KRW', name: 'Won sud-coréen',        symbol: '₩',   flag: '🇰🇷'),
    CurrencyInfo(code: 'HKD', name: 'Dollar de Hong Kong',   symbol: 'HK\$',flag: '🇭🇰'),
    CurrencyInfo(code: 'SGD', name: 'Dollar de Singapour',   symbol: 'S\$', flag: '🇸🇬'),
    CurrencyInfo(code: 'AUD', name: 'Dollar australien',     symbol: 'A\$', flag: '🇦🇺'),
    CurrencyInfo(code: 'NZD', name: 'Dollar néo-zélandais',  symbol: 'NZ\$',flag: '🇳🇿'),
    CurrencyInfo(code: 'INR', name: 'Roupie indienne',       symbol: '₹',   flag: '🇮🇳'),
    CurrencyInfo(code: 'PKR', name: 'Roupie pakistanaise',   symbol: 'PKR', flag: '🇵🇰'),
    CurrencyInfo(code: 'BDT', name: 'Taka bangladais',       symbol: 'BDT', flag: '🇧🇩'),
    CurrencyInfo(code: 'LKR', name: 'Roupie sri-lankaise',   symbol: 'LKR', flag: '🇱🇰'),
    CurrencyInfo(code: 'MYR', name: 'Ringgit malaisien',     symbol: 'MYR', flag: '🇲🇾'),
    CurrencyInfo(code: 'IDR', name: 'Roupie indonésienne',   symbol: 'IDR', flag: '🇮🇩'),
    CurrencyInfo(code: 'THB', name: 'Baht thaïlandais',      symbol: '฿',   flag: '🇹🇭'),
    CurrencyInfo(code: 'PHP', name: 'Peso philippin',        symbol: '₱',   flag: '🇵🇭'),
    CurrencyInfo(code: 'VND', name: 'Dong vietnamien',       symbol: '₫',   flag: '🇻🇳'),
    // ── Afrique ───────────────────────────────────────────
    CurrencyInfo(code: 'ZAR', name: 'Rand sud-africain',     symbol: 'ZAR', flag: '🇿🇦'),
    CurrencyInfo(code: 'NGN', name: 'Naira nigérian',        symbol: '₦',   flag: '🇳🇬'),
    CurrencyInfo(code: 'KES', name: 'Shilling kényan',       symbol: 'KES', flag: '🇰🇪'),
    CurrencyInfo(code: 'GHS', name: 'Cedi ghanéen',          symbol: 'GHS', flag: '🇬🇭'),
    CurrencyInfo(code: 'ETB', name: 'Birr éthiopien',        symbol: 'ETB', flag: '🇪🇹'),
    CurrencyInfo(code: 'XOF', name: 'Franc CFA (BCEAO)',     symbol: 'XOF', flag: '🌍'),
    CurrencyInfo(code: 'XAF', name: 'Franc CFA (BEAC)',      symbol: 'XAF', flag: '🌍'),
    CurrencyInfo(code: 'MUR', name: 'Roupie mauricienne',    symbol: 'MUR', flag: '🇲🇺'),
    CurrencyInfo(code: 'MGA', name: 'Ariary malgache',       symbol: 'MGA', flag: '🇲🇬'),
  ];
}
