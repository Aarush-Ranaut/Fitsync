// gamification_provider.dart
import 'package:flutter/material.dart';

class GamificationProvider with ChangeNotifier {
  int level = 1;
  int points = 0;
  int dailyPoints = 0;
  int streak = 0;
  DateTime? _lastLogin;
  int experience = 0;
  List<String> badges = [];
  Map<String, bool> weeklyChallenges = {
    'Complete 3 workouts': false,
    'Log in 7 days in a row': false,
    'Earn 1000 points': false,
  };

  static const int levelUpThreshold = 1000;

  void addPoints(int newPoints) {
    points += newPoints;
    dailyPoints += newPoints;
    notifyListeners();
  }

  void _checkStreak() {
    DateTime now = DateTime.now();
    if (_lastLogin != null) {
      if (now.difference(_lastLogin!).inDays == 1) {
        streak++; // Continue streak
      } else if (now.difference(_lastLogin!).inDays > 1) {
        streak = 0; // Reset streak
      }
    }
    _lastLogin = now;
    notifyListeners();
  }

  void addExercisePoints(int exerciseId, int durationMinutes) {
    int pointsEarned = durationMinutes * 10; // 10 points per minute
    points += pointsEarned;
    dailyPoints += pointsEarned;
    notifyListeners();
  }

  void resetDailyPoints() {
    dailyPoints = 0;
    notifyListeners();
  }

  void checkStreak() {
    DateTime now = DateTime.now();
    if (_lastLogin != null) {
      if (now.difference(_lastLogin!).inDays == 1) {
        streak++;
      } else if (now.difference(_lastLogin!).inDays > 1) {
        streak = 0;
      }
    }
    _lastLogin = now;
    notifyListeners();
  }
}