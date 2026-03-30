import 'package:flutter/material.dart';
import '../../models/budget_models.dart';
import '../../models/export_models.dart';
import '../../services/transaction_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedPeriod = 1; // 0: Semaine, 1: Mois, 2: Année

  List<BudgetCategory> _categories = [];
  List<RevenueSource> _revenues = [];
  List<TransactionSnapshot> _transactions = [];
  bool _isLoading = true;

  final TransactionService _transactionService = TransactionService();

  IconData _iconFromName(String name) {
    const map = {
      'restaurant': Icons.restaurant_rounded,
      'directions_bus': Icons.directions_bus_rounded,
      'movie': Icons.movie_rounded,
      'menu_book': Icons.menu_book_rounded,
      'favorite': Icons.favorite_rounded,
      'category': Icons.category_rounded,
      'school': Icons.school_rounded,
      'work': Icons.work_rounded,
      'family_restroom': Icons.family_restroom_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs au lieu de 2
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Initialiser les budgets par défaut si nécessaire
    await _transactionService.initializeDefaultBudgets();

    // Charger les budgets
    final budgets = await _transactionService.getBudgets();

    // Charger les transactions en temps réel
    _transactionService.getTransactionsStream().listen((transactions) {
      if (mounted) {
        setState(() {
          _transactions = transactions;
        });
      }
    });

    // Charger les revenus - CORRECTION ICI
    _transactionService.getRevenues().listen((revenues) {
      if (mounted) {
        // Convertir RevenueSnapshot en RevenueSource
        final revenueSources = revenues.map((snapshot) => RevenueSource(
          id: snapshot.id,
          source: snapshot.source,
          amount: snapshot.amount,
          type: snapshot.type,
          iconName: _getIconNameForSource(snapshot.source),
          colorValue: _getColorForSource(snapshot.source),
        )).toList();

        setState(() {
          _revenues = revenueSources;
        });
      }
    });

    if (mounted) {
      setState(() {
        _categories = budgets;
        _isLoading = false;
      });
    }
  }

// Ajoutez ces méthodes helper
  String _getIconNameForSource(String source) {
    if (source.contains('Bourse') || source.contains('bourse')) return 'school';
    if (source.contains('Job') || source.contains('travail')) return 'work';
    if (source.contains('Aide') || source.contains('familiale')) return 'family_restroom';
    return 'attach_money';
  }

  int _getColorForSource(String source) {
    if (source.contains('Bourse') || source.contains('bourse')) return 0xFF3EFFA8;
    if (source.contains('Job') || source.contains('travail')) return 0xFF00D4FF;
    if (source.contains('Aide') || source.contains('familiale')) return 0xFFFFB340;
    return 0xFF8BA8D4;
  }

  // Filtrer les transactions par période
  List<TransactionSnapshot> get _filteredTransactions {
    final now = DateTime.now();

    return _transactions.where((transaction) {
      final transactionDate = transaction.date;

      switch (_selectedPeriod) {
        case 0: // Semaine
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          return transactionDate.isAfter(startOfWeek) &&
              transactionDate.isBefore(endOfWeek);

        case 1: // Mois
          return transactionDate.year == now.year &&
              transactionDate.month == now.month;

        case 2: // Année
          return transactionDate.year == now.year;

        default:
          return true;
      }
    }).toList();
  }

  // Statistiques des transactions filtrées
  double get _filteredTotalExpenses => _filteredTransactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get _filteredTotalIncome => _filteredTransactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get _filteredBalance => _filteredTotalIncome - _filteredTotalExpenses;

  // Rafraîchir les données
  Future<void> _refreshData() async {
    await _loadData();
  }

  BudgetSummary get _summary => BudgetSummary(
    totalBudget: _categories.fold(0, (s, c) => s + c.budget),
    totalSpent: _categories.fold(0, (s, c) => s + c.spent),
  );

  double get _totalRevenue => _revenues.fold(0, (s, r) => s + r.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF3EFFA8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildBudgetSummary(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                  ),
                )
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoriesTab(),
                    _buildTransactionsTab(),
                    _buildRevenueTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budget',
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF3EFFA8),
        icon: const Icon(Icons.add, color: Color(0xFF060D1F)),
        label: const Text('Nouvelle transaction',
            style: TextStyle(color: Color(0xFF060D1F), fontWeight: FontWeight.w700)),
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
              Text('Budget', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              Text('Suivi de vos finances', style: TextStyle(color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAddSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF060D1F), size: 16),
                  SizedBox(width: 4),
                  Text('Ajouter', style: TextStyle(color: Color(0xFF060D1F), fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Semaine', 'Mois', 'Année'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0B1535),
          border: Border.all(color: const Color(0xFF1A2E52)),
        ),
        child: Row(
          children: List.generate(periods.length, (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: _selectedPeriod == i
                      ? const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)])
                      : null,
                ),
                child: Center(
                  child: Text(periods[i],
                      style: TextStyle(
                        color: _selectedPeriod == i ? const Color(0xFF060D1F) : const Color(0xFF4A6080),
                        fontSize: 13,
                        fontWeight: _selectedPeriod == i ? FontWeight.w700 : FontWeight.w400,
                      )),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final s = _summary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(child: _summaryTile('Budget total', '${s.totalBudget.toStringAsFixed(0)} TND', const Color(0xFF8BA8D4))),
          const SizedBox(width: 10),
          Expanded(child: _summaryTile('Dépensé', '${s.totalSpent.toStringAsFixed(0)} TND', const Color(0xFFFF5C7A))),
          const SizedBox(width: 10),
          Expanded(child: _summaryTile('Restant', '${s.remaining.toStringAsFixed(0)} TND', const Color(0xFF3EFFA8))),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF060D1F),
        unselectedLabelColor: const Color(0xFF4A6080),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: 'Catégories'),
          Tab(text: 'Transactions'),
          Tab(text: 'Revenus')
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, color: Color(0xFF4A6080), size: 48),
            SizedBox(height: 12),
            Text('Aucune catégorie de budget',
                style: TextStyle(color: Color(0xFF4A6080))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _categories.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildCategoryCard(_categories[i]),
      ),
    );
  }

  Widget _buildCategoryCard(BudgetCategory cat) {
    final color = Color(cat.colorValue);
    final displayColor = cat.isOver ? const Color(0xFFFF5C7A) : color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(color: cat.isOver ? const Color(0xFFFF5C7A).withOpacity(0.3) : const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: displayColor.withOpacity(0.12)),
                child: Icon(_iconFromName(cat.iconName), color: displayColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('Budget: ${cat.budget.toStringAsFixed(0)} TND', style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${cat.spent.toStringAsFixed(0)} TND', style: TextStyle(color: displayColor, fontSize: 14, fontWeight: FontWeight.w700)),
                  if (cat.isOver) const Text('Dépassé!', style: TextStyle(color: Color(0xFFFF5C7A), fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: cat.progress, minHeight: 5, backgroundColor: const Color(0xFF1A2E52), valueColor: AlwaysStoppedAnimation(displayColor)),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(cat.progress * 100).toStringAsFixed(0)}% utilisé', style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
              Text('Restant: ${cat.remaining.toStringAsFixed(0)} TND', style: TextStyle(color: displayColor, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // Nouvel onglet : Transactions
  Widget _buildTransactionsTab() {
    final filteredTransactions = _filteredTransactions;

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, color: Color(0xFF4A6080), size: 48),
            SizedBox(height: 12),
            Text('Aucune transaction pour cette période',
                style: TextStyle(color: Color(0xFF4A6080))),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistiques de la période
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
            ),
            border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Revenus', style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('+ ${_filteredTotalIncome.toStringAsFixed(0)} TND',
                        style: const TextStyle(color: Color(0xFF3EFFA8), fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0xFF1A2E52)),
              Expanded(
                child: Column(
                  children: [
                    const Text('Dépenses', style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('- ${_filteredTotalExpenses.toStringAsFixed(0)} TND',
                        style: const TextStyle(color: Color(0xFFFF5C7A), fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0xFF1A2E52)),
              Expanded(
                child: Column(
                  children: [
                    const Text('Solde', style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('${_filteredBalance.toStringAsFixed(0)} TND',
                        style: TextStyle(
                          color: _filteredBalance >= 0 ? const Color(0xFF3EFFA8) : const Color(0xFFFF5C7A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste des transactions
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: filteredTransactions.length,
            itemBuilder: (_, i) => _buildTransactionCard(filteredTransactions[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionSnapshot transaction) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? const Color(0xFF3EFFA8) : const Color(0xFFFF5C7A);
    final prefix = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: amountColor.withOpacity(0.12),
            ),
            child: Icon(
              isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: amountColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF1A2E52),
                      ),
                      child: Text(
                        transaction.category,
                        style: const TextStyle(color: Color(0xFF8BA8D4), fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.formattedDate,
                      style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10),
                    ),
                  ],
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.note!,
                    style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$prefix ${transaction.amount.toStringAsFixed(0)} TND',
            style: TextStyle(
              color: amountColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    if (_revenues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up_outlined, color: Color(0xFF4A6080), size: 48),
            SizedBox(height: 12),
            Text('Aucun revenu enregistré',
                style: TextStyle(color: Color(0xFF4A6080))),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFF0F2347), Color(0xFF0B1535)]),
            border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Color(0xFF3EFFA8), size: 28),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenus totaux', style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
                    child: Text('${_totalRevenue.toStringAsFixed(0)} TND', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
        ..._revenues.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildRevenueCard(r))),
      ],
    );
  }

  Widget _buildRevenueCard(RevenueSource r) {
    final color = Color(r.colorValue);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFF0B1535), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.12)),
            child: Icon(_iconFromName(r.iconName), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.source, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: color.withOpacity(0.1)),
                  child: Text(r.type, style: TextStyle(color: color, fontSize: 10)),
                ),
              ],
            ),
          ),
          Text('+ ${r.amount.toStringAsFixed(0)} TND', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AddExpenseSheet(
        categories: _categories,
        onTransactionAdded: _refreshData,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ADD EXPENSE SHEET WITH FIREBASE
// ══════════════════════════════════════════════════════════════
class _AddExpenseSheet extends StatefulWidget {
  final List<BudgetCategory> categories;
  final VoidCallback onTransactionAdded;

  const _AddExpenseSheet({
    required this.categories,
    required this.onTransactionAdded,
  });

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  int _typeIndex = 0;
  String? _selectedCategory;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  bool _isLoading = false;

  final TransactionService _transactionService = TransactionService();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _sourceCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));

    if (amount == null || amount <= 0) {
      _showError('Montant invalide');
      return;
    }

    if (_typeIndex == 0 && _selectedCategory == null) {
      _showError('Veuillez sélectionner une catégorie');
      return;
    }

    if (_typeIndex == 1 && _sourceCtrl.text.trim().isEmpty) {
      _showError('Veuillez indiquer la source du revenu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_typeIndex == 0) {
        // Ajouter une dépense
        await _transactionService.addExpense(
          category: _selectedCategory!,
          amount: amount,
          note: _noteCtrl.text.trim(),
          date: DateTime.now(),
        );

        _showSuccess('Dépense ajoutée avec succès');

      } else {
        // Ajouter un revenu
        await _transactionService.addRevenue(
          source: _sourceCtrl.text.trim(),
          amount: amount,
          type: _typeCtrl.text.trim().isNotEmpty ? _typeCtrl.text.trim() : 'Mensuel',
          date: DateTime.now(),
        );

        _showSuccess('Revenu ajouté avec succès');
      }

      // Rafraîchir les données
      widget.onTransactionAdded();

      // Fermer le bottom sheet
      Navigator.pop(context);

    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF5C7A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF3EFFA8),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF1A2E52), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Nouvelle transaction', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(children: [
              _typeBtn(0, 'Dépense', const Color(0xFFFF5C7A)),
              const SizedBox(width: 10),
              _typeBtn(1, 'Revenu', const Color(0xFF3EFFA8)),
            ]),
            const SizedBox(height: 16),

            if (_typeIndex == 0) ...[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF0D1B38),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _fieldDeco('Catégorie', Icons.category_rounded),
                items: widget.categories.map((c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name)
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),
            ],

            if (_typeIndex == 1) ...[
              TextField(
                controller: _sourceCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _fieldDeco('Source (ex: Salaire, Bourse)', Icons.business_rounded),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _fieldDeco('Fréquence (Mensuel, Hebdomadaire...)', Icons.repeat_rounded),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: _fieldDeco('0.00 TND', Icons.attach_money_rounded),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDeco('Description (optionnel)', Icons.edit_note_rounded),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3EFFA8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                ),
                child: _isLoading
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF060D1F))
                )
                    : const Text('Enregistrer',
                    style: TextStyle(color: Color(0xFF060D1F), fontWeight: FontWeight.w700, fontSize: 15)
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF3A5068)),
    filled: true,
    fillColor: const Color(0xFF0D1B38),
    prefixIcon: Icon(icon, color: const Color(0xFF3EFFA8), size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
  );

  Widget _typeBtn(int idx, String label, Color color) {
    final isSelected = _typeIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _typeIndex = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.15) : const Color(0xFF0D1B38),
            border: Border.all(color: isSelected ? color : const Color(0xFF1A2E52)),
          ),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? color : const Color(0xFF4A6080), fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}