import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – TRANSACTIONS SCREEN
//  Historique complet des dépenses et revenus
// ══════════════════════════════════════════════════════════════

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _filterIndex = 0; // 0=Tout, 1=Dépenses, 2=Revenus
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<_Transaction> _allTransactions = [
    _Transaction(
        label: 'Bourse universitaire',
        category: 'Revenu',
        amount: 600.0,
        date: '01 Mar 2025',
        icon: Icons.school_rounded,
        color: const Color(0xFF3EFFA8),
        isIncome: true),
    _Transaction(
        label: 'Courses alimentaires',
        category: 'Alimentation',
        amount: -45.0,
        date: '02 Mar 2025',
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFFFFB340),
        isIncome: false),
    _Transaction(
        label: 'Transport (métro)',
        category: 'Transport',
        amount: -12.0,
        date: '03 Mar 2025',
        icon: Icons.directions_bus_outlined,
        color: const Color(0xFF00D4FF),
        isIncome: false),
    _Transaction(
        label: 'Job étudiant',
        category: 'Revenu',
        amount: 800.0,
        date: '05 Mar 2025',
        icon: Icons.work_rounded,
        color: const Color(0xFF3EFFA8),
        isIncome: true),
    _Transaction(
        label: 'Cinéma',
        category: 'Loisirs',
        amount: -18.0,
        date: '07 Mar 2025',
        icon: Icons.movie_rounded,
        color: const Color(0xFFFF5C7A),
        isIncome: false),
    _Transaction(
        label: 'Manuel de cours',
        category: 'Académique',
        amount: -35.0,
        date: '08 Mar 2025',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF7B61FF),
        isIncome: false),
    _Transaction(
        label: 'Aide familiale',
        category: 'Revenu',
        amount: 400.0,
        date: '10 Mar 2025',
        icon: Icons.family_restroom_rounded,
        color: const Color(0xFF3EFFA8),
        isIncome: true),
    _Transaction(
        label: 'Restaurant',
        category: 'Alimentation',
        amount: -28.0,
        date: '12 Mar 2025',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFFFB340),
        isIncome: false),
    _Transaction(
        label: 'Pharmacie',
        category: 'Santé',
        amount: -22.0,
        date: '14 Mar 2025',
        icon: Icons.local_pharmacy_rounded,
        color: const Color(0xFF3EFFA8),
        isIncome: false),
    _Transaction(
        label: 'Abonnement Spotify',
        category: 'Loisirs',
        amount: -5.99,
        date: '15 Mar 2025',
        icon: Icons.music_note_rounded,
        color: const Color(0xFFFF5C7A),
        isIncome: false),
  ];

  List<_Transaction> get _filtered {
    return _allTransactions.where((tx) {
      final matchFilter = _filterIndex == 0 ||
          (_filterIndex == 1 && !tx.isIncome) ||
          (_filterIndex == 2 && tx.isIncome);
      final matchSearch = _searchQuery.isEmpty ||
          tx.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            _buildSummaryRow(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transactions',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text('Historique complet',
                  style:
                  TextStyle(color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A2E52)),
              color: const Color(0xFF0D1B38),
            ),
            child: const Icon(Icons.filter_list_rounded,
                color: Color(0xFF8BA8D4), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Rechercher une transaction...',
          hintStyle: const TextStyle(color: Color(0xFF3A5068), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF4A6080), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
            child: const Icon(Icons.close_rounded,
                color: Color(0xFF4A6080), size: 18),
          )
              : null,
          filled: true,
          fillColor: const Color(0xFF0B1535),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A2E52)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A2E52)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tout', 'Dépenses', 'Revenus'];
    final colors = [
      const Color(0xFF8BA8D4),
      const Color(0xFFFF5C7A),
      const Color(0xFF3EFFA8),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(
          filters.length,
              (i) => Padding(
            padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _filterIndex == i
                      ? colors[i].withOpacity(0.15)
                      : const Color(0xFF0B1535),
                  border: Border.all(
                    color: _filterIndex == i
                        ? colors[i]
                        : const Color(0xFF1A2E52),
                  ),
                ),
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: _filterIndex == i
                        ? colors[i]
                        : const Color(0xFF4A6080),
                    fontSize: 13,
                    fontWeight: _filterIndex == i
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final income = _filtered
        .where((t) => t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = _filtered
        .where((t) => !t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount.abs());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Text('${_filtered.length} transaction(s)',
              style: const TextStyle(
                  color: Color(0xFF4A6080), fontSize: 12)),
          const Spacer(),
          if (_filterIndex != 1)
            Text('+${income.toStringAsFixed(0)} TND',
                style: const TextStyle(
                    color: Color(0xFF3EFFA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          if (_filterIndex == 0) const Text('  ·  ',
              style: TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
          if (_filterIndex != 2)
            Text('-${expense.toStringAsFixed(0)} TND',
                style: const TextStyle(
                    color: Color(0xFFFF5C7A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: const Color(0xFF1A2E52), size: 48),
            const SizedBox(height: 12),
            const Text('Aucune transaction trouvée',
                style: TextStyle(color: Color(0xFF4A6080), fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildTxCard(items[i]),
      ),
    );
  }

  Widget _buildTxCard(_Transaction tx) {
    return Dismissible(
      key: Key(tx.label + tx.date),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFFF5C7A).withOpacity(0.2),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Color(0xFFFF5C7A), size: 22),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0B1535),
          border:
          Border.all(color: const Color(0xFF1A2E52).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: tx.color.withOpacity(0.12),
              ),
              child: Icon(tx.icon, color: tx.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: tx.color.withOpacity(0.1),
                        ),
                        child: Text(tx.category,
                            style: TextStyle(
                                color: tx.color, fontSize: 10)),
                      ),
                      const SizedBox(width: 6),
                      Text(tx.date,
                          style: const TextStyle(
                              color: Color(0xFF4A6080), fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${tx.isIncome ? '+' : ''}${tx.amount.toStringAsFixed(2)} TND',
              style: TextStyle(
                color: tx.isIncome
                    ? const Color(0xFF3EFFA8)
                    : const Color(0xFFFF5C7A),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Transaction {
  final String label, category, date;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isIncome;
  const _Transaction({
    required this.label,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
    required this.isIncome,
  });
}