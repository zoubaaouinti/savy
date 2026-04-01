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
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _transactionService.initializeDefaultBudgets();

      _transactionService.getBudgetsStream().listen((budgets) {
        if (mounted) setState(() => _categories = budgets);
      });

      _transactionService.getTransactionsStream().listen((transactions) {
        if (mounted) setState(() => _transactions = transactions);
      });

      _transactionService.getRevenues().listen((revenues) {
        if (mounted) {
          setState(() {
            _revenues = revenues.map((s) => RevenueSource(
              id: s.id,
              source: s.source,
              amount: s.amount,
              type: s.type,
              iconName: _getIconNameForSource(s.source),
              colorValue: _getColorForSource(s.source),
            )).toList();
          });
        }
      });
    } catch (e) {
      print('❌ Erreur chargement: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  double get _totalRevenue => _revenues.fold(0, (s, r) => s + r.amount);

  BudgetSummary get _summary => BudgetSummary(
    totalBudget: _categories.fold(0, (s, c) => s + c.budget),
    totalSpent: _categories.fold(0, (s, c) => s + c.spent),
  );

  Future<void> _refreshData() async => await _loadData();

  Future<void> _editBudgetCategory(BudgetCategory category) async {
    final controller = TextEditingController(text: category.budget.toString());
    final newBudget = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1A2E52)),
        ),
        title: const Text('Modifier le budget',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nouveau budget (TND)',
            labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2E52))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF8BA8D4))),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Montant invalide'),
                      backgroundColor: Color(0xFFFF5C7A)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3EFFA8),
                foregroundColor: const Color(0xFF060D1F)),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (newBudget != null && newBudget != category.budget) {
      await _transactionService.updateBudget(category.name, newBudget);
      _showSuccess('Budget mis à jour');
    }
  }

  Future<void> _deleteTransaction(TransactionSnapshot transaction) async {
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
        content: Text('Voulez-vous vraiment supprimer "${transaction.label}" ?',
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF8BA8D4))),
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

  Future<void> _editTransaction(TransactionSnapshot transaction) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditTransactionDialog(
          transaction: transaction, categories: _categories),
    );
    if (result != null) {
      await _transactionService.updateTransaction(
        transaction.id,
        label: result['label'],
        amount: result['amount'],
        category: result['category'],
        note: result['note'],
      );
      _showSuccess('Transaction modifiée');
    }
  }

  Future<void> _deleteRevenue(RevenueSource revenue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF5C7A)),
        ),
        title: const Text('Supprimer le revenu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer "${revenue.source}" ?',
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF8BA8D4))),
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
      await _transactionService.deleteRevenue(revenue.id);
      _showSuccess('Revenu supprimé');
    }
  }

  Future<void> _editRevenue(RevenueSource revenue) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditRevenueDialog(revenue: revenue),
    );
    if (result != null) {
      await _transactionService.updateRevenue(
        revenue.id,
        source: result['source'],
        amount: result['amount'],
        type: result['type'],
      );
      _showSuccess('Revenu modifié');
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
          onRefresh: _refreshData,
          color: const Color(0xFF3EFFA8),
          strokeWidth: 2.5,
          displacement: 60,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildBudgetSummary(),
                    const SizedBox(height: 16),
                    _buildTabBar(),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: _isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8))))
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
              child: const Row(children: [
                Icon(Icons.add, color: Color(0xFF060D1F), size: 16),
                SizedBox(width: 4),
                Text('Ajouter', style: TextStyle(color: Color(0xFF060D1F), fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final s = _summary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(child: _summaryTile('Budget total', '${s.totalBudget.toStringAsFixed(0)} TND', const Color(0xFF8BA8D4))),
        const SizedBox(width: 10),
        Expanded(child: _summaryTile('Dépensé', '${s.totalSpent.toStringAsFixed(0)} TND', const Color(0xFFFF5C7A))),
        const SizedBox(width: 10),
        Expanded(child: _summaryTile('Restant', '${s.remaining.toStringAsFixed(0)} TND', const Color(0xFF3EFFA8))),
      ]),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          Tab(text: 'Revenus'),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.category_outlined, color: Color(0xFF4A6080), size: 48),
          SizedBox(height: 12),
          Text('Aucune catégorie de budget', style: TextStyle(color: Color(0xFF4A6080))),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(),
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
        border: Border.all(
            color: cat.isOver
                ? const Color(0xFFFF5C7A).withOpacity(0.3)
                : const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: displayColor.withOpacity(0.12)),
            child: Icon(_iconFromName(cat.iconName), color: displayColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('Budget: ${cat.budget.toStringAsFixed(0)} TND',
                  style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
            ]),
          ),
          GestureDetector(
            onTap: () => _editBudgetCategory(cat),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFF3EFFA8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_rounded, color: Color(0xFF3EFFA8), size: 16),
            ),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${cat.spent.toStringAsFixed(0)} TND',
                style: TextStyle(color: displayColor, fontSize: 14, fontWeight: FontWeight.w700)),
            if (cat.isOver)
              const Text('Dépassé!', style: TextStyle(color: Color(0xFFFF5C7A), fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: cat.progress, minHeight: 5,
            backgroundColor: const Color(0xFF1A2E52),
            valueColor: AlwaysStoppedAnimation(displayColor),
          ),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(cat.progress * 100).toStringAsFixed(0)}% utilisé',
              style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
          Text('Restant: ${cat.remaining.toStringAsFixed(0)} TND',
              style: TextStyle(color: displayColor, fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined, color: Color(0xFF4A6080), size: 48),
          SizedBox(height: 12),
          Text('Aucune transaction', style: TextStyle(color: Color(0xFF4A6080))),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (_, i) => _buildTransactionCard(_transactions[i]),
    );
  }

  // ✅ CORRIGÉ — plus d'overflow
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Ligne 1 : icône + label + montant ────────────
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: amountColor.withOpacity(0.12)),
            child: Icon(
              isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: amountColor, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                transaction.label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFF1A2E52)),
                  child: Text(transaction.category,
                      style: const TextStyle(color: Color(0xFF8BA8D4), fontSize: 10)),
                ),
                const SizedBox(width: 6),
                Text(transaction.formattedDate,
                    style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          // Montant — ne cause plus d'overflow
          Text(
            '$prefix ${transaction.amount.toStringAsFixed(0)} TND',
            style: TextStyle(
                color: amountColor, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ]),

        // ── Ligne 2 : note + boutons edit/delete ─────────
        const SizedBox(height: 10),
        Row(children: [
          if (transaction.note != null && transaction.note!.isNotEmpty)
            Expanded(
              child: Text(transaction.note!,
                  style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          else
            const Spacer(),
          GestureDetector(
            onTap: () => _editTransaction(transaction),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFF3EFFA8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_rounded, color: Color(0xFF3EFFA8), size: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteTransaction(transaction),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF5C7A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_rounded, color: Color(0xFFFF5C7A), size: 16),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildRevenueTab() {
    if (_revenues.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.trending_up_outlined, color: Color(0xFF4A6080), size: 48),
          SizedBox(height: 12),
          Text('Aucun revenu enregistré', style: TextStyle(color: Color(0xFF4A6080))),
        ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFF0F2347), Color(0xFF0B1535)]),
            border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded, color: Color(0xFF3EFFA8), size: 28),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Revenus totaux',
                  style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
                child: Text('${_totalRevenue.toStringAsFixed(0)} TND',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        ),
        ..._revenues.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildRevenueCard(r),
        )),
      ],
    );
  }

  Widget _buildRevenueCard(RevenueSource r) {
    final color = Color(r.colorValue);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Ligne 1 : icône + source + montant ───────────
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.12)),
            child: Icon(_iconFromName(r.iconName), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.source,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color.withOpacity(0.1)),
                child: Text(r.type, style: TextStyle(color: color, fontSize: 10)),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Text('+ ${r.amount.toStringAsFixed(0)} TND',
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),

        // ── Ligne 2 : boutons edit/delete ─────────────────
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: () => _editRevenue(r),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFF3EFFA8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_rounded, color: Color(0xFF3EFFA8), size: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteRevenue(r),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF5C7A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_rounded, color: Color(0xFFFF5C7A), size: 16),
            ),
          ),
        ]),
      ]),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AddExpenseSheet(
        categories: _categories,
        onTransactionAdded: _refreshData,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  EDIT TRANSACTION DIALOG
// ══════════════════════════════════════════════════════════════
class _EditTransactionDialog extends StatefulWidget {
  final TransactionSnapshot transaction;
  final List<BudgetCategory> categories;

  const _EditTransactionDialog(
      {required this.transaction, required this.categories});

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  late TextEditingController _labelCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.transaction.label);
    _amountCtrl = TextEditingController(text: widget.transaction.amount.toString());
    _noteCtrl = TextEditingController(text: widget.transaction.note ?? '');
    _selectedCategory = widget.transaction.category;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0B1535),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1A2E52)),
      ),
      title: const Text('Modifier la transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _labelCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Libellé',
              labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: const Color(0xFF0D1B38),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Catégorie',
              labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            ),
            items: widget.categories
                .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Montant (TND)',
              labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Note (optionnel)',
              labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Annuler', style: TextStyle(color: Color(0xFF8BA8D4))),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountCtrl.text);
            if (amount != null && amount > 0 && _labelCtrl.text.isNotEmpty) {
              Navigator.pop(context, {
                'label': _labelCtrl.text,
                'amount': amount,
                'category': _selectedCategory,
                'note': _noteCtrl.text,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Veuillez remplir tous les champs'),
                backgroundColor: Color(0xFFFF5C7A),
              ));
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3EFFA8),
              foregroundColor: const Color(0xFF060D1F)),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  EDIT REVENUE DIALOG
// ══════════════════════════════════════════════════════════════
class _EditRevenueDialog extends StatefulWidget {
  final RevenueSource revenue;
  const _EditRevenueDialog({required this.revenue});

  @override
  State<_EditRevenueDialog> createState() => _EditRevenueDialogState();
}

class _EditRevenueDialogState extends State<_EditRevenueDialog> {
  late TextEditingController _sourceCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _typeCtrl;

  @override
  void initState() {
    super.initState();
    _sourceCtrl = TextEditingController(text: widget.revenue.source);
    _amountCtrl = TextEditingController(text: widget.revenue.amount.toString());
    _typeCtrl = TextEditingController(text: widget.revenue.type);
  }

  @override
  void dispose() {
    _sourceCtrl.dispose();
    _amountCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0B1535),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1A2E52)),
      ),
      title: const Text('Modifier le revenu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _sourceCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Source',
            labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2E52))),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Montant (TND)',
            labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2E52))),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _typeCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Fréquence',
            labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2E52))),
          ),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Annuler', style: TextStyle(color: Color(0xFF8BA8D4))),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountCtrl.text);
            if (amount != null && amount > 0 && _sourceCtrl.text.isNotEmpty) {
              Navigator.pop(context, {
                'source': _sourceCtrl.text,
                'amount': amount,
                'type': _typeCtrl.text,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Veuillez remplir tous les champs'),
                backgroundColor: Color(0xFFFF5C7A),
              ));
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3EFFA8),
              foregroundColor: const Color(0xFF060D1F)),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ADD EXPENSE SHEET
// ══════════════════════════════════════════════════════════════
class _AddExpenseSheet extends StatefulWidget {
  final List<BudgetCategory> categories;
  final VoidCallback onTransactionAdded;

  const _AddExpenseSheet(
      {required this.categories, required this.onTransactionAdded});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  int _typeIndex = 0;
  String? _selectedCategory;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  bool _isLoading = false;

  final TransactionService _transactionService = TransactionService();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final amount =
    double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
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
        await _transactionService.addExpense(
          category: _selectedCategory!,
          amount: amount,
          note: _noteCtrl.text.trim(),
          date: DateTime.now(),
        );
        _showSuccess('Dépense ajoutée avec succès');
      } else {
        await _transactionService.addRevenue(
          source: _sourceCtrl.text.trim(),
          amount: amount,
          type: 'Mensuel',
          date: DateTime.now(),
        );
        _showSuccess('Revenu ajouté avec succès');
      }
      widget.onTransactionAdded();
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFFF5C7A),
          behavior: SnackBarBehavior.floating));

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF3EFFA8),
          behavior: SnackBarBehavior.floating));

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
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFF1A2E52),
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Nouvelle transaction',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
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
                items: widget.categories
                    .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
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
            ],
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: _fieldDeco('Montant (TND)', Icons.attach_money_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDeco('Description (optionnel)', Icons.edit_note_rounded),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3EFFA8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF060D1F)))
                    : const Text('Enregistrer',
                    style: TextStyle(color: Color(0xFF060D1F),
                        fontWeight: FontWeight.w700, fontSize: 15)),
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
    filled: true, fillColor: const Color(0xFF0D1B38),
    prefixIcon: Icon(icon, color: const Color(0xFF3EFFA8), size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A2E52))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A2E52))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
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
          child: Center(child: Text(label,
              style: TextStyle(color: isSelected ? color : const Color(0xFF4A6080),
                  fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}