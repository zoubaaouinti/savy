import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – OBJECTIVES SCREEN
//  Objectifs d'épargne avec suivi de progression
// ══════════════════════════════════════════════════════════════

class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  State<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  final List<_Objective> _objectives = [
    _Objective(
        name: 'Ordinateur portable',
        icon: Icons.laptop_rounded,
        current: 360,
        target: 900,
        deadline: 'Juin 2025',
        priority: 1,
        color: const Color(0xFF3EFFA8),
        suggestion: 180),
    _Objective(
        name: 'Voyage Europe',
        icon: Icons.flight_rounded,
        current: 150,
        target: 600,
        deadline: 'Août 2025',
        priority: 2,
        color: const Color(0xFF00D4FF),
        suggestion: 90),
    _Objective(
        name: 'Fond d\'urgence',
        icon: Icons.shield_rounded,
        current: 200,
        target: 500,
        deadline: 'Déc 2025',
        priority: 3,
        color: const Color(0xFFFFB340),
        suggestion: 50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildGlobalProgress(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: _objectives.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildObjectiveCard(_objectives[i]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddObjectiveSheet(context),
        backgroundColor: const Color(0xFF3EFFA8),
        icon: const Icon(Icons.add, color: Color(0xFF060D1F)),
        label: const Text('Nouvel objectif',
            style: TextStyle(
                color: Color(0xFF060D1F), fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objectifs',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text('Vos objectifs d\'épargne',
                  style:
                  TextStyle(color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF0B1535),
              border: Border.all(color: const Color(0xFF1A2E52)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sort_rounded,
                    color: Color(0xFF8BA8D4), size: 16),
                SizedBox(width: 4),
                Text('Priorité',
                    style: TextStyle(
                        color: Color(0xFF8BA8D4), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalProgress() {
    final totalSaved =
    _objectives.fold<double>(0, (s, o) => s + o.current);
    final totalTarget =
    _objectives.fold<double>(0, (s, o) => s + o.target);
    final progress = totalSaved / totalTarget;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
          ),
          border: Border.all(
              color: const Color(0xFF3EFFA8).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.savings_rounded,
                    color: Color(0xFF3EFFA8), size: 20),
                const SizedBox(width: 10),
                const Text('Épargne totale',
                    style: TextStyle(
                        color: Color(0xFF8BA8D4),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: Color(0xFF3EFFA8),
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF1A2E52),
                valueColor:
                const AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${totalSaved.toStringAsFixed(0)} TND épargnés',
                  style: const TextStyle(
                      color: Color(0xFF3EFFA8), fontSize: 12),
                ),
                Text(
                  'Objectif: ${totalTarget.toStringAsFixed(0)} TND',
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveCard(_Objective obj) {
    final progress = (obj.current / obj.target).clamp(0.0, 1.0);
    final remaining = obj.target - obj.current;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: obj.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: obj.color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Priority badge
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: obj.color.withOpacity(0.15),
                    border: Border.all(color: obj.color.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(
                      '${obj.priority}',
                      style: TextStyle(
                          color: obj.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: obj.color.withOpacity(0.12),
                  ),
                  child: Icon(obj.icon, color: obj.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(obj.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Color(0xFF4A6080), size: 11),
                          const SizedBox(width: 4),
                          Text(obj.deadline,
                              style: const TextStyle(
                                  color: Color(0xFF4A6080), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${obj.current.toStringAsFixed(0)} TND',
                      style: TextStyle(
                          color: obj.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '/ ${obj.target.toStringAsFixed(0)} TND',
                      style: const TextStyle(
                          color: Color(0xFF4A6080), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1A2E52),
                    valueColor: AlwaysStoppedAnimation(obj.color),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% atteint',
                      style: TextStyle(color: obj.color, fontSize: 11),
                    ),
                    Text(
                      'Manque: ${remaining.toStringAsFixed(0)} TND',
                      style: const TextStyle(
                          color: Color(0xFF4A6080), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Suggestion strip
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: obj.color.withOpacity(0.06),
              border: Border.all(color: obj.color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: obj.color, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Suggestion: épargner ${obj.suggestion.toStringAsFixed(0)} TND / mois',
                    style: TextStyle(color: obj.color, fontSize: 12),
                  ),
                ),
                // Accept button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: obj.color.withOpacity(0.15),
                      border:
                      Border.all(color: obj.color.withOpacity(0.4)),
                    ),
                    child: Text('Accepter',
                        style: TextStyle(
                            color: obj.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddObjectiveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text('Nouvel objectif',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _sheetField('Nom de l\'objectif', Icons.flag_rounded),
              const SizedBox(height: 12),
              _sheetField('Montant cible (TND)', Icons.savings_rounded,
                  isNumber: true),
              const SizedBox(height: 12),
              _sheetField('Date limite', Icons.calendar_today_rounded),
              const SizedBox(height: 20),
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
                  child: const Text('Créer l\'objectif',
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
      ),
    );
  }

  Widget _sheetField(String hint, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      keyboardType:
      isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3A5068)),
        filled: true,
        fillColor: const Color(0xFF0D1B38),
        prefixIcon:
        Icon(icon, color: const Color(0xFF3EFFA8), size: 20),
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
    );
  }
}

class _Objective {
  final String name, deadline;
  final IconData icon;
  final double current, target, suggestion;
  final int priority;
  final Color color;
  const _Objective({
    required this.name,
    required this.icon,
    required this.current,
    required this.target,
    required this.deadline,
    required this.priority,
    required this.color,
    required this.suggestion,
  });
}