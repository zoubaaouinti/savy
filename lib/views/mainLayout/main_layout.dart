import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../budgetScreen/budget_screen.dart';
import '../home/home_screen.dart';
import '../objectivesScreen/objectives_screen.dart';
import '../profileScreen/profile_screen.dart';
import '../transactionsScreen/transactions_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Controllers d'animation pour chaque tab
  late final List<AnimationController> _tabControllers;
  late final List<Animation<double>> _tabScales;

  // Pages indexées
  final List<Widget> _pages = const [
    HomeScreen(),
    BudgetScreen(),
    ObjectivesScreen(),
    TransactionsScreen(),
    ProfileScreen(),
  ];

  // Config de la navbar
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded,       label: 'Accueil'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Budget'),
    _NavItem(icon: Icons.flag_rounded,            label: 'Objectifs'),
    _NavItem(icon: Icons.receipt_long_rounded,    label: 'Dépenses'),
    _NavItem(icon: Icons.person_rounded,          label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _tabControllers = List.generate(
      _navItems.length,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _tabScales = _tabControllers.map((c) {
      return Tween<double>(begin: 1.0, end: 1.18).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOutBack),
      );
    }).toList();

    // Active le premier tab
    _tabControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _tabControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();

    // Reset ancien tab
    _tabControllers[_currentIndex].reverse();

    setState(() => _currentIndex = index);

    // Anime le nouveau tab
    _tabControllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      // IndexedStack garde les pages en mémoire (pas de rebuild)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1535),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1A2E52).withOpacity(0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              // Tab central (index 2 = Objectifs) → bouton FAB spécial
              if (i == 2) return _buildCenterFab(i);
              return _buildNavTab(i);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(int index) {
    final isActive = _currentIndex == index;
    final item = _navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _tabScales[index],
          builder: (_, __) => Transform.scale(
            scale: _tabScales[index].value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicateur actif (point lumineux)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 24 : 0,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                    ),
                  ),
                ),
                // Icône
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isActive
                        ? const Color(0xFF3EFFA8).withOpacity(0.12)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: isActive
                        ? const Color(0xFF3EFFA8)
                        : const Color(0xFF3A5570),
                  ),
                ),
                const SizedBox(height: 2),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? const Color(0xFF3EFFA8)
                        : const Color(0xFF3A5570),
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab(int index) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Center(
          child: AnimatedBuilder(
            animation: _tabScales[index],
            builder: (_, __) => Transform.scale(
              scale: _tabScales[index].value,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isActive
                        ? [const Color(0xFF3EFFA8), const Color(0xFF00D4FF)]
                        : [
                      const Color(0xFF1A2E52),
                      const Color(0xFF1A2E52),
                    ],
                  ),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: const Color(0xFF3EFFA8).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Icon(
                  Icons.flag_rounded,
                  size: 24,
                  color: isActive
                      ? const Color(0xFF060D1F)
                      : const Color(0xFF3A5570),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item model ────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}