import 'package:flutter/material.dart';

class Objective {
  final String name;
  final String deadline;
  final double current;
  final double target;
  final double suggestion;
  final int priority;
  final Color color;
  final IconData icon;

  Objective({
    required this.name,
    required this.deadline,
    required this.current,
    required this.target,
    required this.suggestion,
    required this.priority,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'deadline': deadline,
      'current': current,
      'target': target,
      'suggestion': suggestion,
      'priority': priority,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  factory Objective.fromMap(Map<String, dynamic> map) {
    return Objective(
      name: map['name'],
      deadline: map['deadline'],
      current: (map['current'] as num).toDouble(),
      target: (map['target'] as num).toDouble(),
      suggestion: (map['suggestion'] as num).toDouble(),
      priority: map['priority'],
      color: Color(map['color']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}