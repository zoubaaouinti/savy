import 'package:flutter/material.dart';
import '../../services/transaction_service.dart';
import '../../models/export_models.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – TRANSACTIONS SCREEN
//  Historique complet des dépenses et revenus (avec données réelles)
//  ✅ Les revenus (RevenueSnapshot) sont fusionnés avec les transactions
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

  List<TransactionSnapshot> _allTransactions = [];
  List<RevenueSnapshot> _allRevenues = [];
  bool _isLoading = true;

  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // ── Écouter les transactions ────────────────────────────
      _transactionService.getTransactionsStream().listen((transactions) {
        if (mounted) {
          setState(() {
            _allTransactions = transactions;
            _isLoading = false;
          });
        }
      });

      _transactionService.getRevenuesStream().listen((revenues) {
        if (mounted) {
          setState(() {
            _allRevenues = revenues;
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement données: $e');
      setState(() => _isLoading = false);
    }
  }

  // ── Convertir un RevenueSnapshot en TransactionSnapshot ────
  TransactionSnapshot _revenueToTransaction(RevenueSnapshot rev) {
    return TransactionSnapshot(
      id: 'rev_${rev.id}',
      label: rev.source,
      amount: rev.amount,
      category: rev.type, // ex: 'Mensuel', 'Bourse', 'Job', etc.
      isIncome: true,
      date: DateTime.now(), // Les revenus n'ont pas de date, on utilise aujourd'hui
      note: null,
    );
  }

  // ── Liste fusionnée : transactions + revenus convertis ──────
  List<TransactionSnapshot> get _merged {
    final revenueAsTx = _allRevenues.map(_revenueToTransaction).toList();
    final merged = [..._allTransactions, ...revenueAsTx];
    // Tri par date décroissante
    merged.sort((a, b) => b.date.compareTo(a.date));
    return merged;
  }

  List<TransactionSnapshot> get _filtered {
    return _merged.where((tx) {
      final matchFilter = _filterIndex == 0 ||
          (_filterIndex == 1 && !tx.isIncome) ||
          (_filterIndex == 2 && tx.isIncome);
      final matchSearch = _searchQuery.isEmpty ||
          tx.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  double get _totalIncome => _filtered
      .where((t) => t.isIncome)
      .fold<double>(0, (s, t) => s + t.amount);

  double get _totalExpense => _filtered
      .where((t) => !t.isIncome)
      .fold<double>(0, (s, t) => s + t.amount);

  IconData _getIconForCategory(String category, bool isIncome) {
    if (isIncome) {
      final cat = category.toLowerCase();
      if (cat.contains('bourse') || cat.contains('étudiant'))
        return Icons.school_rounded;
      if (cat.contains('job') || cat.contains('travail') || cat.contains('salaire'))
        return Icons.work_rounded;
      if (cat.contains('aide') || cat.contains('familiale') || cat.contains('famille'))
        return Icons.family_restroom_rounded;
      if (cat.contains('freelance') || cat.contains('mission'))
        return Icons.laptop_rounded;
      if (cat.contains('mensuel'))
        return Icons.calendar_month_rounded;
      return Icons.trending_up_rounded;
    }

    switch (category.toLowerCase()) {
      case 'alimentation':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'loisirs':
        return Icons.movie_rounded;
      case 'académique':
        return Icons.menu_book_rounded;
      case 'santé':
        return Icons.local_pharmacy_rounded;
      default:
        return Icons.shopping_cart_outlined;
    }
  }

  Color _getColorForCategory(String category, bool isIncome) {
    if (isIncome) return const Color(0xFF3EFFA8);

    switch (category.toLowerCase()) {
      case 'alimentation':
        return const Color(0xFFFFB340);
      case 'transport':
        return const Color(0xFF00D4FF);
      case 'loisirs':
        return const Color(0xFFFF5C7A);
      case 'académique':
        return const Color(0xFF7B61FF);
      case 'santé':
        return const Color(0xFF3EFFA8);
      default:
        return const Color(0xFF8BA8D4);
    }
  }

  Future<void> _deleteTransaction(TransactionSnapshot transaction) async {
    // ⚠️ Ne pas supprimer les revenus convertis depuis cette page
    if (transaction.id.startsWith('rev_')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Supprimez ce revenu depuis la page Revenus.'),
        backgroundColor: Color(0xFF8BA8D4),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF5C7A)),
        ),
        title: const Text('Supprimer la transaction',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
            'Voulez-vous vraiment supprimer "${transaction.label}" ?',
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF8BA8D4))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C7A),
                foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _transactionService.deleteTransaction(transaction.id);
      _showSuccess('Transaction supprimée');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF3EFFA8),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF3EFFA8),
          strokeWidth: 2.5,
          displacement: 60,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              _buildSummaryRow(),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                  ),
                )
                    : _buildList(),
              ),
            ],
          ),
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
                  style: TextStyle(color: Color(0xFF4A6080), fontSize: 13)),
            ],
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
          hintStyle:
          const TextStyle(color: Color(0xFF3A5068), fontSize: 14),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Text('${_filtered.length} transaction(s)',
              style: const TextStyle(
                  color: Color(0xFF4A6080), fontSize: 12)),
          const Spacer(),
          if (_filterIndex != 1)
            Text('+${_totalIncome.toStringAsFixed(0)} TND',
                style: const TextStyle(
                    color: Color(0xFF3EFFA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          if (_filterIndex == 0)
            const Text('  ·  ',
                style: TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
          if (_filterIndex != 2)
            Text('-${_totalExpense.toStringAsFixed(0)} TND',
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
            const Icon(Icons.search_off_rounded,
                color: Color(0xFF1A2E52), size: 48),
            const SizedBox(height: 12),
            const Text('Aucune transaction trouvée',
                style:
                TextStyle(color: Color(0xFF4A6080), fontSize: 14)),
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

  Widget _buildTxCard(TransactionSnapshot tx) {
    final isIncome = tx.isIncome;
    final amountColor =
    isIncome ? const Color(0xFF3EFFA8) : const Color(0xFFFF5C7A);
    final icon = _getIconForCategory(tx.category, isIncome);
    final color = _getColorForCategory(tx.category, isIncome);
    final prefix = isIncome ? '+' : '-';
    final isRevenue = tx.id.startsWith('rev_');

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (isRevenue) {
          _showRevenueDeleteHint();
          return false; // Bloquer le swipe pour les revenus
        }
        return true;
      },
      onDismissed: (_) => _deleteTransaction(tx),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isRevenue
              ? const Color(0xFF3EFFA8).withOpacity(0.1)
              : const Color(0xFFFF5C7A).withOpacity(0.2),
        ),
        child: Icon(
          isRevenue ? Icons.info_outline_rounded : Icons.delete_outline_rounded,
          color: isRevenue
              ? const Color(0xFF3EFFA8)
              : const Color(0xFFFF5C7A),
          size: 22,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0B1535),
          border: Border.all(
            color: isRevenue
                ? const Color(0xFF3EFFA8).withOpacity(0.15)
                : const Color(0xFF1A2E52).withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            // ── Icône de catégorie ──────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // ── Infos ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tx.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge "Revenu" pour distinguer visuellement
                      if (isRevenue)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xFF3EFFA8).withOpacity(0.1),
                            border: Border.all(
                                color: const Color(0xFF3EFFA8).withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Revenu',
                            style: TextStyle(
                                color: Color(0xFF3EFFA8),
                                fontSize: 9,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: color.withOpacity(0.1),
                        ),
                        child: Text(tx.category,
                            style: TextStyle(color: color, fontSize: 10)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tx.formattedDate,
                        style: const TextStyle(
                            color: Color(0xFF4A6080), fontSize: 10),
                      ),
                    ],
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        tx.note!,
                        style: const TextStyle(
                            color: Color(0xFF4A6080), fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // ── Montant ─────────────────────────────────────
            Text(
              '$prefix ${tx.amount.toStringAsFixed(2)} TND',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRevenueDeleteHint() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Supprimez ce revenu depuis la page Revenus.'),
      backgroundColor: Color(0xFF1A2E52),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }
}