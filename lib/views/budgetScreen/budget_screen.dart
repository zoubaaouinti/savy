import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savy/l10n/app_localizations.dart';
import '../../models/budget_models.dart';
import '../../models/export_models.dart';
import '../../providers/currency_provider.dart';
import '../../services/transaction_service.dart';
import '../../utils/category_translator.dart';

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

  // ------------------------------------------------------------
  //  HELPERS (icônes, couleurs)
  // ------------------------------------------------------------
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
      'attach_money': Icons.attach_money_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }

  // Liste des icônes disponibles pour les catégories personnalisées
  final List<String> _availableIcons = [
    'restaurant', 'directions_bus', 'movie', 'menu_book',
    'favorite', 'category', 'school', 'work', 'family_restroom',
    'attach_money', 'shopping_cart', 'local_pharmacy', 'sports_esports',
    'flight', 'home', 'computer', 'book', 'music_note', 'brush'
  ];

  // Liste des couleurs disponibles
  final List<int> _availableColors = [
    0xFFFFB340, 0xFF00D4FF, 0xFFFF5C7A, 0xFF7B61FF, 0xFF3EFFA8,
    0xFF8BA8D4, 0xFFFF6B6B, 0xFF4ECDC4, 0xFFFFE66D, 0xFFA8E6CF
  ];

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

  // ------------------------------------------------------------
  //  CRUD CATÉGORIES
  // ------------------------------------------------------------
  Future<void> _addNewCategory() async {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    String name = '';
    double budget = 0;
    String iconName = 'category';
    int colorValue = 0xFF8BA8D4;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.budgetNewCategory,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryName),
                  onChanged: (v) => name = v,
                  validator: (v) => v == null || v.isEmpty ? l10n.errorRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryBudgetLabel),
                  onChanged: (v) => budget = double.tryParse(v) ?? 0,
                  validator: (v) => v == null || double.tryParse(v) == null ? l10n.errorInvalidAmount : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: iconName,
                  dropdownColor: const Color(0xFF0D1B38),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryIcon),
                  items: _availableIcons.map((icon) {
                    return DropdownMenuItem(
                      value: icon,
                      child: Row(children: [
                        Icon(_iconFromName(icon), size: 20, color: const Color(0xFF3EFFA8)),
                        const SizedBox(width: 8),
                        Text(icon),
                      ]),
                    );
                  }).toList(),
                  onChanged: (v) => iconName = v!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: colorValue,
                  dropdownColor: const Color(0xFF0D1B38),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryColor),
                  items: _availableColors.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Row(children: [
                        Container(width: 24, height: 24, color: Color(color)),
                        const SizedBox(width: 8),
                        Text('#${color.toRadixString(16)}'),
                      ]),
                    );
                  }).toList(),
                  onChanged: (v) => colorValue = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _transactionService.addBudgetCategory(
                  name: name,
                  budget: budget,
                  iconName: iconName,
                  colorValue: colorValue,
                );
                Navigator.pop(context);
                _showSuccess(l10n.budgetDeleteSuccess);
              }
            },
            child: Text(l10n.budgetCategoryCreate),
          ),
        ],
      ),
    );
  }

  Future<void> _editFullCategory(BudgetCategory category) async {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    String name = category.name;
    double budget = category.budget;
    String iconName = category.iconName;
    int colorValue = category.colorValue;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.budgetNewCategory,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryName),
                  onChanged: (v) => name = v,
                  validator: (v) => v == null || v.isEmpty ? l10n.errorRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: budget.toString(),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryBudgetLabel),
                  onChanged: (v) => budget = double.tryParse(v) ?? 0,
                  validator: (v) => v == null || double.tryParse(v) == null ? l10n.errorInvalidAmount : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: iconName,
                  dropdownColor: const Color(0xFF0D1B38),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryIcon),
                  items: _availableIcons.map((icon) {
                    return DropdownMenuItem(
                      value: icon,
                      child: Row(children: [
                        Icon(_iconFromName(icon), size: 20, color: const Color(0xFF3EFFA8)),
                        const SizedBox(width: 8),
                        Text(icon),
                      ]),
                    );
                  }).toList(),
                  onChanged: (v) => iconName = v!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: colorValue,
                  dropdownColor: const Color(0xFF0D1B38),
                  decoration: InputDecoration(labelText: l10n.budgetCategoryColor),
                  items: _availableColors.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Row(children: [
                        Container(width: 24, height: 24, color: Color(color)),
                        const SizedBox(width: 8),
                        Text('#${color.toRadixString(16)}'),
                      ]),
                    );
                  }).toList(),
                  onChanged: (v) => colorValue = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _transactionService.updateBudgetCategory(
                  id: category.id,
                  name: name,
                  budget: budget,
                  iconName: iconName,
                  colorValue: colorValue,
                );
                Navigator.pop(context);
                _showSuccess(l10n.budgetDeleteSuccess);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BudgetCategory category) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.budgetDeleteCategory,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '${l10n.budgetDeleteConfirm} "${CategoryTranslator.byIconName(category.iconName, l10n)}" ?',
          style: const TextStyle(color: Color(0xFF8BA8D4)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C7A)),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _transactionService.deleteBudgetCategory(category.id);
        _showSuccess(l10n.budgetDeleteSuccess);
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  // ------------------------------------------------------------
  //  MODIFICATION DU BUDGET (montant seulement) – ancienne méthode
  // ------------------------------------------------------------
  Future<void> _editBudgetAmount(BudgetCategory category) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: category.budget.toString());
    final newBudget = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.budgetCategoryBudgetLabel,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.budgetCategoryBudgetLabel,
            labelStyle: const TextStyle(color: Color(0xFF8BA8D4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) Navigator.pop(context, value);
              else _showError(l10n.errorInvalidAmount);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newBudget != null && newBudget != category.budget) {
      await _transactionService.updateBudget(category.id, newBudget);
      _showSuccess(l10n.budgetDeleteSuccess);
    }
  }

  // ------------------------------------------------------------
  //  TRANSACTIONS (avec ID de catégorie)
  // ------------------------------------------------------------
  Future<void> _deleteTransaction(TransactionSnapshot transaction) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.budgetDeleteCategory,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('${l10n.budgetDeleteConfirm} "${transaction.label}" ?',
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C7A)),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _transactionService.deleteTransaction(transaction.id);
      _showSuccess(l10n.budgetDeleteSuccess);
    }
  }

  Future<void> _editTransaction(TransactionSnapshot transaction) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditTransactionDialog(
        transaction: transaction,
        categories: _categories,
      ),
    );
    if (result != null) {
      await _transactionService.updateTransaction(
        transaction.id,
        label: result['label'],
        amount: result['amount'],
        categoryId: result['categoryId'],
        note: result['note'],
      );
      _showSuccess(AppLocalizations.of(context).budgetDeleteSuccess);
    }
  }

  // ------------------------------------------------------------
  //  REVENUS
  // ------------------------------------------------------------
  Future<void> _deleteRevenue(RevenueSource revenue) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.budgetDeleteRevenue,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('${l10n.budgetDeleteConfirm} "${revenue.source}" ?',
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C7A)),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _transactionService.deleteRevenue(revenue.id);
      _showSuccess(l10n.budgetDeleteSuccess);
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
      _showSuccess(AppLocalizations.of(context).budgetDeleteSuccess);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF3EFFA8),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFFFF5C7A),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ------------------------------------------------------------
  //  UI BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildBudgetSummary(context),
                  const SizedBox(height: 16),
                  _buildTabBar(context),
                ],
              ),
            ),
          ],
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8))))
              : RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF3EFFA8),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(context),
                _buildTransactionsTab(context),
                _buildRevenueTab(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budget',
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF3EFFA8),
        icon: const Icon(Icons.add, color: Color(0xFF060D1F)),
        label: Text(l10n.budgetAddTransaction,
            style: const TextStyle(color: Color(0xFF060D1F), fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.budgetTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              Text(l10n.budgetSubtitle, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _addNewCategory,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
              ),
              child: Row(children: [
                const Icon(Icons.add, color: Color(0xFF060D1F), size: 16),
                const SizedBox(width: 4),
                Text(l10n.budgetAddCategory, style: const TextStyle(color: Color(0xFF060D1F), fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = _summary;
    final cur = context.watch<CurrencyProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(child: _summaryTile(l10n.budgetTotal, cur.format(s.totalBudget), const Color(0xFF8BA8D4))),
        const SizedBox(width: 10),
        Expanded(child: _summaryTile(l10n.budgetSpent, cur.format(s.totalSpent), const Color(0xFFFF5C7A))),
        const SizedBox(width: 10),
        Expanded(child: _summaryTile(l10n.budgetRemaining, cur.format(s.remaining), const Color(0xFF3EFFA8))),
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

  Widget _buildTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        tabs: [
          Tab(text: l10n.budgetTabBudget),
          Tab(text: l10n.budgetTabExpenses),
          Tab(text: l10n.budgetTabRevenues),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  //  ONGLET CATÉGORIES
  // ------------------------------------------------------------
  Widget _buildCategoriesTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_categories.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.category_outlined, color: Color(0xFF4A6080), size: 48),
          const SizedBox(height: 12),
          Text(l10n.budgetNoCategoryTitle, style: const TextStyle(color: Color(0xFF4A6080))),
          const SizedBox(height: 8),
          Text(l10n.budgetNoCategoryHint, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
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
    final l10n = AppLocalizations.of(context);
    final cur = context.watch<CurrencyProvider>();
    final color = Color(cat.colorValue);
    final displayColor = cat.isOver ? const Color(0xFFFF5C7A) : color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(
          color: cat.isOver ? const Color(0xFFFF5C7A).withOpacity(0.3) : const Color(0xFF1A2E52).withOpacity(0.6),
        ),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: displayColor.withOpacity(0.12)),
            child: Icon(_iconFromName(cat.iconName), color: displayColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(CategoryTranslator.byIconName(cat.iconName, l10n), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${l10n.budgetTotal}: ${cur.format(cat.budget)}', style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
            ]),
          ),
          GestureDetector(
            onTap: () => _editFullCategory(cat),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF3EFFA8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_rounded, color: Color(0xFF3EFFA8), size: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteCategory(cat),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFF5C7A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_rounded, color: Color(0xFFFF5C7A), size: 16),
            ),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(cur.format(cat.spent), style: TextStyle(color: displayColor, fontSize: 14, fontWeight: FontWeight.w700)),
            if (cat.isOver) Text(l10n.budgetOverspent, style: const TextStyle(color: Color(0xFFFF5C7A), fontSize: 10)),
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
          Text('${(cat.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
          Text('${l10n.budgetRemaining}: ${cur.format(cat.remaining)}', style: TextStyle(color: displayColor, fontSize: 10)),
        ]),
      ]),
    );
  }

  // ------------------------------------------------------------
  //  ONGLET TRANSACTIONS
  // ------------------------------------------------------------
  Widget _buildTransactionsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_transactions.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.receipt_long_outlined, color: Color(0xFF4A6080), size: 48),
          const SizedBox(height: 12),
          Text(l10n.budgetNoCategoryTitle, style: const TextStyle(color: Color(0xFF4A6080))),
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

  Widget _buildTransactionCard(TransactionSnapshot transaction) {
    final l10n = AppLocalizations.of(context);
    final cur = context.watch<CurrencyProvider>();
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
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: amountColor.withOpacity(0.12)),
            child: Icon(isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: amountColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(CategoryTranslator.resolveLabel(transaction.label, transaction.category, l10n), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: const Color(0xFF1A2E52)),
                  child: Text(CategoryTranslator.byStoredName(transaction.category, l10n), style: const TextStyle(color: Color(0xFF8BA8D4), fontSize: 10)),
                ),
                const SizedBox(width: 6),
                Text(transaction.formattedDate, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text('$prefix ${cur.format(transaction.amount)}', style: TextStyle(color: amountColor, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          if (transaction.note != null && transaction.note!.isNotEmpty)
            Expanded(child: Text(transaction.note!, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))
          else
            const Spacer(),
          GestureDetector(
            onTap: () => _editTransaction(transaction),
            child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFF3EFFA8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_rounded, color: Color(0xFF3EFFA8), size: 16)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteTransaction(transaction),
            child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFFFF5C7A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_rounded, color: Color(0xFFFF5C7A), size: 16)),
          ),
        ]),
      ]),
    );
  }

  // ------------------------------------------------------------
  //  ONGLET REVENUS
  // ------------------------------------------------------------
  Widget _buildRevenueTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_revenues.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.trending_up_outlined, color: Color(0xFF4A6080), size: 48),
          const SizedBox(height: 12),
          Text(l10n.budgetNoRevenueTitle, style: const TextStyle(color: Color(0xFF4A6080))),
          const SizedBox(height: 8),
          Text(l10n.budgetNoRevenueHint, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
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
              Text(l10n.budgetTabRevenues, style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
                child: Text(context.watch<CurrencyProvider>().format(_totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        ),
        ..._revenues.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildRevenueCard(r))),
      ],
    );
  }

  Widget _buildRevenueCard(RevenueSource r) {
    final cur = context.watch<CurrencyProvider>();
    final color = Color(r.colorValue);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.12)),
            child: Icon(_iconFromName(r.iconName), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.source, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: color.withOpacity(0.1)),
                child: Text(r.type, style: TextStyle(color: color, fontSize: 10)),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Text('+ ${cur.format(r.amount)}', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: () => _editRevenue(r),
            child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFF3EFFA8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_rounded, color: Color(0xFF3EFFA8), size: 16)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteRevenue(r),
            child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFFFF5C7A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_rounded, color: Color(0xFFFF5C7A), size: 16)),
          ),
        ]),
      ]),
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

// ==============================================================
//  EDIT TRANSACTION DIALOG (corrigé — nullable firstWhere)
// ==============================================================
class _EditTransactionDialog extends StatefulWidget {
  final TransactionSnapshot transaction;
  final List<BudgetCategory> categories;

  const _EditTransactionDialog({required this.transaction, required this.categories});

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  late TextEditingController _labelCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late String _selectedCategoryId;
  late String _selectedCategoryName;

  @override
  bool _labelInitialized = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.transaction.label);
    _amountCtrl = TextEditingController(text: widget.transaction.amount.toString());
    _noteCtrl = TextEditingController(text: widget.transaction.note ?? '');

    // Match par iconName (nouveau format) ou par name (ancien format)
    final matchingCat = widget.categories.cast<BudgetCategory?>().firstWhere(
          (c) => c!.iconName == widget.transaction.category ||
                 c!.name == widget.transaction.category,
      orElse: () => widget.categories.isNotEmpty ? widget.categories.first : null,
    );
    if (matchingCat != null) {
      _selectedCategoryId = matchingCat.id;
      _selectedCategoryName = matchingCat.name;
    } else {
      _selectedCategoryId = '';
      _selectedCategoryName = '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_labelInitialized) {
      _labelInitialized = true;
      final l10n = AppLocalizations.of(context);
      // Pré-remplir avec le libellé résolu (traduit si auto-généré en français)
      _labelCtrl.text = CategoryTranslator.resolveLabel(
          widget.transaction.label, widget.transaction.category, l10n);
    }
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFF0B1535),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.budgetAddTransaction, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _labelCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l10n.budgetTransactionLabel)),
          const SizedBox(height: 12),
          DropdownButtonFormField<BudgetCategory?>(
            value: _selectedCategoryId.isNotEmpty
                ? widget.categories.cast<BudgetCategory?>().firstWhere(
                  (c) => c!.id == _selectedCategoryId,
              orElse: () => null,
            )
                : null,
            dropdownColor: const Color(0xFF0D1B38),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(labelText: l10n.budgetNoCategoryTitle),
            items: widget.categories.map((c) {
              return DropdownMenuItem<BudgetCategory?>(
                value: c,
                child: Row(children: [
                  Icon(_iconFromName(c.iconName), size: 18, color: Color(c.colorValue)),
                  const SizedBox(width: 8),
                  Text(CategoryTranslator.byIconName(c.iconName, l10n)),
                ]),
              );
            }).toList(),
            onChanged: (BudgetCategory? newCat) {
              if (newCat != null) {
                setState(() {
                  _selectedCategoryId = newCat.id;
                  _selectedCategoryName = newCat.name;
                  if (!widget.transaction.isIncome && (_labelCtrl.text.isEmpty || _labelCtrl.text == widget.transaction.label)) {
                    _labelCtrl.text = CategoryTranslator.byIconName(newCat.iconName, AppLocalizations.of(context));
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _amountCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l10n.budgetTransactionAmount)),
          const SizedBox(height: 12),
          TextField(controller: _noteCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l10n.budgetTransactionNote)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountCtrl.text);
            if (amount != null && amount > 0 && _labelCtrl.text.isNotEmpty && _selectedCategoryId.isNotEmpty) {
              Navigator.pop(context, {
                'label': _labelCtrl.text,
                'amount': amount,
                'categoryId': _selectedCategoryId,
                'categoryName': _selectedCategoryName,
                'note': _noteCtrl.text,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric), backgroundColor: const Color(0xFFFF5C7A)));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3EFFA8), foregroundColor: const Color(0xFF060D1F)),
          child: Text(l10n.save),
        ),
      ],
    );
  }

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
      'attach_money': Icons.attach_money_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }
}

// ==============================================================
//  EDIT REVENUE DIALOG
// ==============================================================
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFF0B1535),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.budgetDeleteRevenue, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _sourceCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l10n.budgetRevenueSource)),
        const SizedBox(height: 12),
        TextField(controller: _amountCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l10n.budgetTransactionAmount)),
        const SizedBox(height: 12),
        TextField(controller: _typeCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l10n.budgetRevenueType)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountCtrl.text);
            if (amount != null && amount > 0 && _sourceCtrl.text.isNotEmpty) {
              Navigator.pop(context, {'source': _sourceCtrl.text, 'amount': amount, 'type': _typeCtrl.text});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric), backgroundColor: const Color(0xFFFF5C7A)));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3EFFA8), foregroundColor: const Color(0xFF060D1F)),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

// ==============================================================
//  ADD EXPENSE SHEET (corrigé — nullable firstWhere)
// ==============================================================
class _AddExpenseSheet extends StatefulWidget {
  final List<BudgetCategory> categories;
  final VoidCallback onTransactionAdded;

  const _AddExpenseSheet({required this.categories, required this.onTransactionAdded});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  int _typeIndex = 0;
  String? _selectedCategoryId;
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
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _showError(l10n.errorInvalidAmount);
      return;
    }
    if (_typeIndex == 0 && _selectedCategoryId == null) {
      _showError(l10n.errorRequired);
      return;
    }
    if (_typeIndex == 1 && _sourceCtrl.text.trim().isEmpty) {
      _showError(l10n.errorRequired);
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_typeIndex == 0) {
        await _transactionService.addExpense(
          categoryId: _selectedCategoryId!,
          amount: amount,
          note: _noteCtrl.text.trim(),
          date: DateTime.now(),
        );
        _showSuccess(l10n.budgetDeleteSuccess);
      } else {
        await _transactionService.addRevenue(
          source: _sourceCtrl.text.trim(),
          amount: amount,
          type: 'Mensuel',
          date: DateTime.now(),
          note: _noteCtrl.text.trim(),
        );
        _showSuccess(l10n.budgetDeleteSuccess);
      }
      widget.onTransactionAdded();
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFFF5C7A), behavior: SnackBarBehavior.floating));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF3EFFA8), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            Text(l10n.budgetAddTransaction, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(children: [
              _typeBtn(0, l10n.budgetSpent, const Color(0xFFFF5C7A)),
              const SizedBox(width: 10),
              _typeBtn(1, l10n.budgetTabRevenues, const Color(0xFF3EFFA8)),
            ]),
            const SizedBox(height: 16),
            if (_typeIndex == 0) ...[
              DropdownButtonFormField<BudgetCategory?>(
                value: _selectedCategoryId != null
                    ? widget.categories.cast<BudgetCategory?>().firstWhere(
                      (c) => c!.id == _selectedCategoryId,
                  orElse: () => null,
                )
                    : null,
                dropdownColor: const Color(0xFF0D1B38),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _fieldDeco(l10n.budgetNoCategoryTitle, Icons.category_rounded),
                items: widget.categories.map((c) {
                  return DropdownMenuItem<BudgetCategory?>(
                    value: c,
                    child: Row(children: [
                      Icon(_iconFromName(c.iconName), size: 18, color: Color(c.colorValue)),
                      const SizedBox(width: 8),
                      Text(CategoryTranslator.byIconName(c.iconName, l10n)),
                    ]),
                  );
                }).toList(),
                onChanged: (cat) => setState(() => _selectedCategoryId = cat?.id),
              ),
              const SizedBox(height: 12),
            ],
            if (_typeIndex == 1) ...[
              TextField(controller: _sourceCtrl, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: _fieldDeco(l10n.budgetRevenueSource, Icons.business_rounded)),
              const SizedBox(height: 12),
            ],
            TextField(controller: _amountCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 18), decoration: _fieldDeco(l10n.budgetTransactionAmount, Icons.attach_money_rounded)),
            const SizedBox(height: 12),
            TextField(controller: _noteCtrl, style: const TextStyle(color: Colors.white), decoration: _fieldDeco(l10n.budgetTransactionNote, Icons.edit_note_rounded)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3EFFA8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF060D1F)))
                    : Text(l10n.save, style: const TextStyle(color: Color(0xFF060D1F), fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
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
      'attach_money': Icons.attach_money_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }
}
