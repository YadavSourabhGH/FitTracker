import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Maps stored icon names to icon data.
IconData iconForName(String name) {
  switch (name) {
    case 'dumbbell':
      return LucideIcons.dumbbell;
    case 'footprints':
      return LucideIcons.footprints;
    case 'flame':
      return LucideIcons.flame;
    case 'droplets':
      return LucideIcons.droplets;
    case 'target':
      return LucideIcons.target;
    case 'apple':
      return LucideIcons.apple;
    case 'award':
      return LucideIcons.award;
    case 'crown':
      return LucideIcons.crown;
    case 'mapPin':
      return LucideIcons.mapPin;
    case 'zap':
      return LucideIcons.zap;
    case 'scale':
      return LucideIcons.scale;
    case 'moon':
      return LucideIcons.moon;
    case 'trophy':
      return Icons.emoji_events_outlined;
    default:
      return LucideIcons.sparkles;
  }
}

/// Icon for a workout category.
IconData iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'hiit':
      return LucideIcons.zap;
    case 'cardio':
      return LucideIcons.footprints;
    case 'mobility':
      return Icons.self_improvement;
    case 'hypertrophy':
      return LucideIcons.dumbbell;
    default:
      return Icons.fitness_center;
  }
}
