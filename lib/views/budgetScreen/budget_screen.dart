import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – BUDGET SCREEN
//  Gestion revenus & dépenses, budget restant par catégorie
// ══════════════════════════════════════════════════════════════

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedPeriod = 1; // 0=Semaine, 1=Mois, 2=Année

  final List<_BudgetCategory> _categories = [
    _BudgetCategory(
        name: 'Alimentation',
        icon: Icons.restaurant_rounded,
        spent: 145,
        budget: 200,
        color: const Color(0xFFFFB340)),
    _BudgetCategory(
        name: 'Transport',
        icon: Icons.directions_bus_rounded,
        spent: 48,
        budget: 60,
        color: const Color(0xFF00D4FF)),
    _BudgetCategory(
        name: 'Loisirs',
        icon: Icons.movie_rounded,
        spent: 80,
        budget: 70,
        color: const Color(0xFFFF5C7A)),
    _BudgetCategory(
        name: 'Académique',
        icon: Icons.menu_book_rounded,
        spent: 60,
        budget: 100,
        color: const Color(0xFF7B61FF)),
    _BudgetCategory(
        name: 'Santé',
        icon: Icons.favorite_rounded,
        spent: 30,
        budget: 50,
        color: const Color(0xFF3EFFA8)),
    _BudgetCategory(
        name: 'Autres',
        icon: Icons.category_rounded,
        spent: 20,
        budget: 40,
        color: const Color(0xFF8BA8D4)),
  ];

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
                children: [
                  _buildCategoriesTab(),
                  _buildRevenueTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
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
              Text('Budget',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text('Suivi de vos finances',
                  style:
                  TextStyle(color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          // Add expense button
          GestureDetector(
            onTap: () => _showAddSheet(context),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF060D1F), size: 16),
                  SizedBox(width: 4),
                  Text('Ajouter',
                      style: TextStyle(
                          color: Color(0xFF060D1F),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
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
          children: List.generate(
            periods.length,
                (i) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: _selectedPeriod == i
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF3EFFA8),
                        Color(0xFF00D4FF)
                      ],
                    )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      periods[i],
                      style: TextStyle(
                        color: _selectedPeriod == i
                            ? const Color(0xFF060D1F)
                            : const Color(0xFF4A6080),
                        fontSize: 13,
                        fontWeight: _selectedPeriod == i
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final totalBudget =
    _categories.fold<double>(0, (s, c) => s + c.budget);
    final totalSpent =
    _categories.fold<double>(0, (s, c) => s + c.spent);
    final remaining = totalBudget - totalSpent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryTile(
                'Budget total',
                '${totalBudget.toStringAsFixed(0)} TND',
                const Color(0xFF8BA8D4)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryTile('Dépensé',
                '${totalSpent.toStringAsFixed(0)} TND',
                const Color(0xFFFF5C7A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryTile('Restant',
                '${remaining.toStringAsFixed(0)} TND',
                const Color(0xFF3EFFA8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color) {
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
          Text(label,
              style:
              const TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF060D1F),
        unselectedLabelColor: const Color(0xFF4A6080),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: 'Catégories'),
          Tab(text: 'Revenus'),
        ],
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

  Widget _buildCategoryCard(_BudgetCategory cat) {
    final progress = (cat.spent / cat.budget).clamp(0.0, 1.0);
    final isOver = cat.spent > cat.budget;
    final displayColor = isOver ? const Color(0xFFFF5C7A) : cat.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(
            color: isOver
                ? const Color(0xFFFF5C7A).withOpacity(0.3)
                : const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: displayColor.withOpacity(0.12),
                ),
                child: Icon(cat.icon, color: displayColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(
                      'Budget: ${cat.budget.toStringAsFixed(0)} TND',
                      style: const TextStyle(
                          color: Color(0xFF4A6080), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${cat.spent.toStringAsFixed(0)} TND',
                    style: TextStyle(
                        color: displayColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  if (isOver)
                    const Text('Dépassé!',
                        style: TextStyle(
                            color: Color(0xFFFF5C7A), fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFF1A2E52),
              valueColor: AlwaysStoppedAnimation(displayColor),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% utilisé',
                style:
                const TextStyle(color: Color(0xFF4A6080), fontSize: 10),
              ),
              Text(
                'Restant: ${(cat.budget - cat.spent).toStringAsFixed(0)} TND',
                style: TextStyle(color: displayColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    final revenues = [
      _RevenueData(
          source: 'Bourse universitaire',
          amount: 600,
          type: 'Mensuel',
          icon: Icons.school_rounded,
          color: const Color(0xFF3EFFA8)),
      _RevenueData(
          source: 'Job étudiant',
          amount: 800,
          type: 'Mensuel',
          icon: Icons.work_rounded,
          color: const Color(0xFF00D4FF)),
      _RevenueData(
          source: 'Aide familiale',
          amount: 400,
          type: 'Irrégulier',
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFFFFB340)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        // Total revenue card
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
            ),
            border: Border.all(
                color: const Color(0xFF3EFFA8).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: Color(0xFF3EFFA8), size: 28),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenus totaux',
                      style: TextStyle(
                          color: Color(0xFF6B8CAE), fontSize: 12)),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                    ).createShader(b),
                    child: const Text(
                      '1 800 TND',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...revenues.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildRevenueCard(r),
        )),
      ],
    );
  }

  Widget _buildRevenueCard(_RevenueData r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(
            color: r.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: r.color.withOpacity(0.12),
            ),
            child: Icon(r.icon, color: r.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.source,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: r.color.withOpacity(0.1),
                  ),
                  child: Text(r.type,
                      style: TextStyle(color: r.color, fontSize: 10)),
                ),
              ],
            ),
          ),
          Text(
            '+ ${r.amount.toStringAsFixed(0)} TND',
            style: TextStyle(
                color: r.color,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddSheet(context),
      backgroundColor: const Color(0xFF3EFFA8),
      icon: const Icon(Icons.add, color: Color(0xFF060D1F)),
      label: const Text('Nouvelle dépense',
          style: TextStyle(
              color: Color(0xFF060D1F), fontWeight: FontWeight.w700)),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AddExpenseSheet(),
    );
  }
}

// ── Add Expense Bottom Sheet ─────────────────────────────────
class _AddExpenseSheet extends StatefulWidget {
  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  int _typeIndex = 0; // 0=Dépense, 1=Revenu
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2E52),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nouvelle transaction',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            // Type toggle
            Row(
              children: [
                _buildTypeBtn(0, 'Dépense', const Color(0xFFFF5C7A)),
                const SizedBox(width: 10),
                _buildTypeBtn(1, 'Revenu', const Color(0xFF3EFFA8)),
              ],
            ),
            const SizedBox(height: 16),
            // Amount field
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: '0.00 TND',
                hintStyle: const TextStyle(color: Color(0xFF3A5068)),
                filled: true,
                fillColor: const Color(0xFF0D1B38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: Color(0xFF1A2E52)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: Color(0xFF1A2E52)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
                ),
                prefixIcon: const Icon(Icons.attach_money_rounded,
                    color: Color(0xFF3EFFA8)),
              ),
            ),
            const SizedBox(height: 12),
            // Note field
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Description (optionnel)',
                hintStyle: const TextStyle(color: Color(0xFF3A5068)),
                filled: true,
                fillColor: const Color(0xFF0D1B38),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFF1A2E52))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFF1A2E52))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
                prefixIcon: const Icon(Icons.edit_note_rounded,
                    color: Color(0xFF3EFFA8)),
              ),
            ),
            const SizedBox(height: 20),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3EFFA8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Enregistrer',
                    style: TextStyle(
                        color: Color(0xFF060D1F),
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBtn(int idx, String label, Color color) {
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
            border: Border.all(
                color: isSelected ? color : const Color(0xFF1A2E52)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? color : const Color(0xFF4A6080),
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────
class _BudgetCategory {
  final String name;
  final IconData icon;
  final double spent, budget;
  final Color color;
  const _BudgetCategory(
      {required this.name,
        required this.icon,
        required this.spent,
        required this.budget,
        required this.color});
}

class _RevenueData {
  final String source, type;
  final double amount;
  final IconData icon;
  final Color color;
  const _RevenueData(
      {required this.source,
        required this.amount,
        required this.type,
        required this.icon,
        required this.color});
}