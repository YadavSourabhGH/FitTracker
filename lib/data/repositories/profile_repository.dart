import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

/// Repository managing athlete profile, streak consistency, and XP leveling.
class ProfileRepository {
  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Athlete';
    final gender = prefs.getString('user_gender') ?? 'male';
    final streak = prefs.getInt('user_streak') ?? 0;
    final level = prefs.getInt('user_level') ?? 1;
    final currentXp = prefs.getInt('user_xp') ?? 0;

    final defaultProfile = UserProfile.defaultProfile(name: name, gender: gender);

    return UserProfile(
      name: name,
      bio: defaultProfile.bio,
      location: defaultProfile.location,
      gender: gender,
      memberSince: defaultProfile.memberSince,
      level: level,
      currentXp: currentXp,
      maxXp: defaultProfile.maxXp,
      streakDays: streak,
      weekActivityDots: defaultProfile.weekActivityDots,
      movePercentage: defaultProfile.movePercentage,
      exercisePercentage: defaultProfile.exercisePercentage,
      hydrationPercentage: defaultProfile.hydrationPercentage,
      achievements: defaultProfile.achievements,
    );
  }

  Future<void> addXp(int xpEarned) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXp = prefs.getInt('user_xp') ?? 0;
    final currentLevel = prefs.getInt('user_level') ?? 1;

    int newXp = currentXp + xpEarned;
    int newLevel = currentLevel;

    if (newXp >= 1000) {
      newXp = newXp - 1000;
      newLevel += 1;
    }

    await prefs.setInt('user_xp', newXp);
    await prefs.setInt('user_level', newLevel);
  }
}
