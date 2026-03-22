import 'package:flutter/material.dart';
import '../../models/budget_models.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedPeriod = 1;

  final List<BudgetCategory> _categories = [
    BudgetCategory(name: 'Alimentation', spent: 145, budget: 200, iconName: 'restaurant', colorValue: 0xFFFFB340),
    BudgetCategory(name: 'Transport', spent: 48, budget: 60, iconName: 'directions_bus', colorValue: 0xFF00D4FF),
    BudgetCategory(name: 'Loisirs', spent: 80, budget: 70, iconName: 'movie', colorValue: 0xFFFF5C7A),
    BudgetCategory(name: 'Académique', spent: 60, budget: 100, iconName: 'menu_book', colorValue: 0xFF7B61FF),
    BudgetCategory(name: 'Santé', spent: 30, budget: 50, iconName: 'favorite', colorValue: 0xFF3EFFA8),
    BudgetCategory(name: 'Autres', spent: 20, budget: 40, iconName: 'category', colorValue: 0xFF8BA8D4),
  ];

  final List<RevenueSource> _revenues = [
    RevenueSource(id: '1', source: 'Bourse universitaire', amount: 600, type: 'Mensuel', iconName: 'school', colorValue: 0xFF3EFFA8),
    RevenueSource(id: '2', source: 'Job étudiant', amount: 800, type: 'Mensuel', iconName: 'work', colorValue: 0xFF00D4FF),
    RevenueSource(id: '3', source: 'Aide familiale', amount: 400, type: 'Irrégulier', iconName: 'family_restroom', colorValue: 0xFFFFB340),
  ];

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildPeriodSelector(),
            _buildBudgetSummary(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCategoriesTab(), _buildRevenueTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budget',
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF3EFFA8),
        icon: const Icon(Icons.add, color: Color(0xFF060D1F)),
        label: const Text('Nouvelle dépense',
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
        tabs: const [Tab(text: 'Catégories'), Tab(text: 'Revenus')],
      ),
    );
  }

  Widget _buildCategoriesTab() {
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

  Widget _buildRevenueTab() {
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
      builder: (_) => _AddExpenseSheet(categories: _categories),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ADD EXPENSE SHEET
// ══════════════════════════════════════════════════════════════
class _AddExpenseSheet extends StatefulWidget {
  final List<BudgetCategory> categories;
  const _AddExpenseSheet({required this.categories});
  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  int _typeIndex = 0;
  String? _selectedCategory;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() { _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

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
                items: widget.categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),
            ],
            TextField(controller: _amountCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: _fieldDeco('0.00 TND', Icons.attach_money_rounded)),
            const SizedBox(height: 12),
            TextField(controller: _noteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDeco('Description (optionnel)', Icons.edit_note_rounded)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3EFFA8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Enregistrer', style: TextStyle(color: Color(0xFF060D1F), fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Color(0xFF3A5068)),
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
}