import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  MODEL – Objective
//  lib/models/objective.dart
// ══════════════════════════════════════════════════════════════

class Objective {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final int priority;
  final String deadline;
  final Timestamp? deadlineTimestamp;
  final String icon;
  final String color;
  final double suggestion;
  final DateTime? createdAt;

  const Objective({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.priority,
    required this.deadline,
    this.deadlineTimestamp,
    required this.icon,
    required this.color,
    required this.suggestion,
    this.createdAt,
  });

  // ── Firestore → Model ──────────────────────────────────────
  factory Objective.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Objective(
      id: doc.id,
      name: d['name'] ?? '',
      targetAmount: (d['targetAmount'] ?? 0).toDouble(),
      currentAmount: (d['currentAmount'] ?? 0).toDouble(),
      priority: (d['priority'] ?? 1) as int,
      deadline: d['deadline'] ?? '',
      deadlineTimestamp: d['deadlineTimestamp'] as Timestamp?,
      icon: d['icon'] ?? 'savings',
      color: d['color'] ?? '#3EFFA8',
      suggestion: (d['suggestion'] ?? 0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── Model → Firestore ──────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'priority': priority,
    'deadline': deadline,
    'deadlineTimestamp': deadlineTimestamp,
    'icon': icon,
    'color': color,
    'suggestion': suggestion,
    'createdAt': FieldValue.serverTimestamp(),
  };

  // ── Computed ───────────────────────────────────────────────
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  // ── Static helpers ─────────────────────────────────────────
  static IconData iconFromName(String name) {
    const map = {
      'laptop': Icons.laptop_rounded,
      'flight': Icons.flight_rounded,
      'shield': Icons.shield_rounded,
      'car': Icons.directions_car_rounded,
      'home': Icons.home_rounded,
      'school': Icons.school_rounded,
      'phone': Icons.smartphone_rounded,
      'savings': Icons.savings_rounded,
      'flag': Icons.flag_rounded,
    };
    return map[name] ?? Icons.savings_rounded;
  }

  static Color colorFromHex(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));

  static const List<String> availableColors = [
    '#3EFFA8', '#00D4FF', '#FFB340',
    '#FF6B8A', '#A78BFA', '#60A5FA',
  ];

  static const Map<String, IconData> availableIcons = {
    'savings': Icons.savings_rounded,
    'laptop': Icons.laptop_rounded,
    'flight': Icons.flight_rounded,
    'car': Icons.directions_car_rounded,
    'home': Icons.home_rounded,
    'school': Icons.school_rounded,
    'phone': Icons.smartphone_rounded,
    'shield': Icons.shield_rounded,
    'flag': Icons.flag_rounded,
  };
}