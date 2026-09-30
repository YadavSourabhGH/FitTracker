/// User profile, leveling, and streak models matching the UI reference.
class UserProfile {
  final String name;
  final String bio;
  final String location;
  final String gender;
  final String memberSince;
  final int level;
  final int currentXp;
  final int maxXp;
  final int streakDays;
  final List<bool> weekActivityDots; // [S, M, T, W, T, F, S]
  final double movePercentage;
  final double exercisePercentage;
  final double hydrationPercentage;
  final List<AchievementBadge> achievements;

  const UserProfile({
    required this.name,
    required this.bio,
    required this.location,
    required this.gender,
    required this.memberSince,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.streakDays,
    required this.weekActivityDots,
    required this.movePercentage,
    required this.exercisePercentage,
    required this.hydrationPercentage,
    required this.achievements,
  });

  /// Default baseline for newly onboarded athlete
  factory UserProfile.defaultProfile({String? name, String? gender}) {
    return UserProfile(
      name: name ?? 'Athlete',
      bio: 'Focused on daily progress.',
      location: 'Active Tracker',
      gender: gender ?? 'male',
      memberSince: 'Today',
      level: 1,
      currentXp: 0,
      maxXp: 1000,
      streakDays: 0,
      weekActivityDots: const [false, false, false, false, false, false, false],
      movePercentage: 0.0,
      exercisePercentage: 0.0,
      hydrationPercentage: 0.0,
      achievements: const [
        AchievementBadge(id: '1', title: '1 Day', subtitle: 'Streak', iconName: 'flame', isUnlocked: false),
        AchievementBadge(id: '2', title: '10k', subtitle: 'Steps', iconName: 'shoe', isUnlocked: false),
        AchievementBadge(id: '3', title: 'Hydration', subtitle: 'Hero', iconName: 'droplet', isUnlocked: false),
        AchievementBadge(id: '4', title: 'Goal', subtitle: 'Crusher', iconName: 'target', isUnlocked: false),
        AchievementBadge(id: '5', title: '2 Weeks', subtitle: 'Streak', iconName: 'lock', isUnlocked: false),
      ],
    );
  }
}

class AchievementBadge {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final bool isUnlocked;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.isUnlocked,
  });
}
