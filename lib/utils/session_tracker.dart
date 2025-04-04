// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SessionTracker with WidgetsBindingObserver {
//   static final SessionTracker _instance = SessionTracker._internal();
//   factory SessionTracker() => _instance;
//   SessionTracker._internal() {
//     WidgetsBinding.instance.addObserver(this);
//     _startSessionTimer();
//   }

//   DateTime? _sessionStartTime;
//   double _sessionDuration = 0.0; // Accumulated session time in minutes
//   Timer? _sessionTimer;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? _userId;

//   // Initialize the session tracker with the current user
//   void initialize() {
//     _userId = FirebaseAuth.instance.currentUser?.uid;
//     if (_userId != null) {
//       _startSessionTimer();
//     }
//   }

//   // Start the periodic timer to update session time
//   void _startSessionTimer() {
//     _sessionStartTime = DateTime.now();
//     _sessionTimer?.cancel();
//     _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _updateSessionTime();
//     });
//   }

//   // Update the session duration and save to Firestore
//   void _updateSessionTime() async {
//     if (_sessionStartTime == null || _userId == null) return;

//     final now = DateTime.now();
//     final duration = now.difference(_sessionStartTime!).inSeconds / 60.0;
//     _sessionDuration += duration;

//     // Check for day transition
//     final startDay = DateTime(
//       _sessionStartTime!.year,
//       _sessionStartTime!.month,
//       _sessionStartTime!.day,
//     );
//     final nowDay = DateTime(now.year, now.month, now.day);

//     if (startDay != nowDay) {
//       // Split the duration across days
//       final midnight = DateTime(
//         _sessionStartTime!.year,
//         _sessionStartTime!.month,
//         _sessionStartTime!.day,
//         23,
//         59,
//         59,
//         999,
//       );
//       final durationUntilMidnight =
//           midnight.difference(_sessionStartTime!).inSeconds / 60.0;
//       final durationAfterMidnight = now
//               .difference(midnight.add(const Duration(milliseconds: 1)))
//               .inSeconds /
//           60.0;

//       await _saveSessionTime(durationUntilMidnight, _sessionStartTime!);
//       await _saveSessionTime(durationAfterMidnight, now);
//     } else {
//       await _saveSessionTime(_sessionDuration, now);
//     }

//     _sessionStartTime = now;
//     _sessionDuration = 0.0;
//   }

//   // Save the session time to Firestore
//   Future<void> _saveSessionTime(double duration, DateTime date) async {
//     if (duration <= 0 || _userId == null) return;

//     try {
//       DocumentReference timeDocRef = _firestore
//           .collection('users')
//           .doc(_userId)
//           .collection('gamification')
//           .doc('timeSpent');

//       await _firestore.runTransaction((transaction) async {
//         DocumentSnapshot timeDoc = await transaction.get(timeDocRef);
//         int dayIndex = date.weekday - 1; // 0 (Mon) to 6 (Sun)

//         List<double> updatedDailyTime;
//         Timestamp? lastUpdated;

//         if (timeDoc.exists) {
//           lastUpdated = timeDoc['lastUpdated'];
//           updatedDailyTime = List<double>.from(timeDoc['dailyTime']);

//           if (lastUpdated != null) {
//             DateTime lastUpdatedDate = lastUpdated.toDate();
//             if (!_isSameWeek(lastUpdatedDate, date)) {
//               updatedDailyTime = List.filled(7, 0.0);
//             }
//           }
//         } else {
//           updatedDailyTime = List.filled(7, 0.0);
//         }

//         updatedDailyTime[dayIndex] += duration;

//         transaction.set(timeDocRef, {
//           'dailyTime': updatedDailyTime,
//           'lastUpdated': FieldValue.serverTimestamp(),
//         });
//       });
//     } catch (e) {
//       print("Error saving session time: $e");
//     }
//   }

//   // Check if two dates are in the same week
//   bool _isSameWeek(DateTime a, DateTime b) {
//     final firstDayOfWeekA = a.subtract(Duration(days: a.weekday - 1));
//     final firstDayOfWeekB = b.subtract(Duration(days: b.weekday - 1));
//     return firstDayOfWeekA.year == firstDayOfWeekB.year &&
//         firstDayOfWeekA.month == firstDayOfWeekB.month &&
//         firstDayOfWeekA.day == firstDayOfWeekB.day;
//   }

//   // Fetch the daily time spent data
//   Future<List<double>> getDailyTimeSpent() async {
//     if (_userId == null) return List.filled(7, 0.0);

//     try {
//       final DocumentSnapshot timeDoc = await _firestore
//           .collection('users')
//           .doc(_userId)
//           .collection('gamification')
//           .doc('timeSpent')
//           .get();

//       if (timeDoc.exists) {
//         final data = timeDoc.data() as Map<String, dynamic>;
//         final List<dynamic> dailyTime =
//             data['dailyTime'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
//         final Timestamp? lastUpdated = data['lastUpdated'];

//         if (lastUpdated != null) {
//           DateTime lastUpdatedDate = lastUpdated.toDate();
//           if (!_isSameWeek(lastUpdatedDate, DateTime.now())) {
//             return List.filled(7, 0.0);
//           }
//         }

//         return dailyTime.map((item) => (item as num).toDouble()).toList();
//       }
//     } catch (e) {
//       print("Error fetching daily time spent: $e");
//     }
//     return List.filled(7, 0.0);
//   }

//   // Subscribe to real-time updates of daily time spent
//   Stream<List<double>> streamDailyTimeSpent() {
//     if (_userId == null) {
//       return Stream.value(List.filled(7, 0.0));
//     }

//     return _firestore
//         .collection('users')
//         .doc(_userId)
//         .collection('gamification')
//         .doc('timeSpent')
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.exists) {
//         final data = snapshot.data() as Map<String, dynamic>;
//         final List<dynamic> dailyTime =
//             data['dailyTime'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
//         return dailyTime.map((item) => (item as num).toDouble()).toList();
//       }
//       return List.filled(7, 0.0);
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _updateSessionTime();
//     } else if (state == AppLifecycleState.resumed) {
//       _startSessionTimer();
//     }
//   }

//   // Clean up when the app is closed
//   void dispose() {
//     _sessionTimer?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//   }
// }

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionTracker with WidgetsBindingObserver {
  static final SessionTracker _instance = SessionTracker._internal();
  factory SessionTracker() => _instance;
  SessionTracker._internal() {
    WidgetsBinding.instance.addObserver(this);
    _startSessionTimer();
    _listenToAuthChanges(); // Listen to auth state changes
  }

  DateTime? _sessionStartTime;
  double _sessionDuration = 0.0; // Accumulated session time in minutes
  Timer? _sessionTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  // Listen to auth state changes to update _userId
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _userId = user?.uid;
      if (_userId != null) {
        _startSessionTimer();
      } else {
        _sessionTimer?.cancel();
        _sessionStartTime = null;
        _sessionDuration = 0.0;
      }
    });
  }

  // Explicit initialization if needed (e.g., called from GamificationScreen)
  void initialize() {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      _startSessionTimer();
    }
  }

  // Start the periodic timer to update session time
  void _startSessionTimer() {
    _sessionStartTime = DateTime.now();
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateSessionTime();
    });
  }

  // Update the session duration and save to Firestore
  void _updateSessionTime() async {
    if (_sessionStartTime == null || _userId == null) return;

    final now = DateTime.now();
    final duration = now.difference(_sessionStartTime!).inSeconds / 60.0;
    _sessionDuration += duration;

    // Check for day transition
    final startDay = DateTime(
      _sessionStartTime!.year,
      _sessionStartTime!.month,
      _sessionStartTime!.day,
    );
    final nowDay = DateTime(now.year, now.month, now.day);

    if (startDay != nowDay) {
      // Split the duration across days
      final midnight = DateTime(
        _sessionStartTime!.year,
        _sessionStartTime!.month,
        _sessionStartTime!.day,
        23,
        59,
        59,
        999,
      );
      final durationUntilMidnight =
          midnight.difference(_sessionStartTime!).inSeconds / 60.0;
      final durationAfterMidnight = now
              .difference(midnight.add(const Duration(milliseconds: 1)))
              .inSeconds /
          60.0;

      await _saveSessionTime(durationUntilMidnight, _sessionStartTime!);
      await _saveSessionTime(durationAfterMidnight, now);
    } else {
      await _saveSessionTime(_sessionDuration, now);
    }

    _sessionStartTime = now;
    _sessionDuration = 0.0;
  }

  // Save the session time to Firestore
  Future<void> _saveSessionTime(double duration, DateTime date) async {
    if (duration <= 0 || _userId == null) return;

    try {
      DocumentReference timeDocRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('gamification')
          .doc('timeSpent');

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot timeDoc = await transaction.get(timeDocRef);
        int dayIndex = date.weekday - 1; // 0 (Mon) to 6 (Sun)

        List<double> updatedDailyTime;
        Timestamp? lastUpdated;

        if (timeDoc.exists) {
          lastUpdated = timeDoc['lastUpdated'];
          updatedDailyTime = List<double>.from(timeDoc['dailyTime']);

          if (lastUpdated != null) {
            DateTime lastUpdatedDate = lastUpdated.toDate();
            if (!_isSameWeek(lastUpdatedDate, date)) {
              updatedDailyTime = List.filled(7, 0.0);
            }
          }
        } else {
          updatedDailyTime = List.filled(7, 0.0);
        }

        updatedDailyTime[dayIndex] += duration;

        transaction.set(timeDocRef, {
          'dailyTime': updatedDailyTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print("Error saving session time: $e");
    }
  }

  // Check if two dates are in the same week
  bool _isSameWeek(DateTime a, DateTime b) {
    final firstDayOfWeekA = a.subtract(Duration(days: a.weekday - 1));
    final firstDayOfWeekB = b.subtract(Duration(days: b.weekday - 1));
    return firstDayOfWeekA.year == firstDayOfWeekB.year &&
        firstDayOfWeekA.month == firstDayOfWeekB.month &&
        firstDayOfWeekA.day == firstDayOfWeekB.day;
  }

  // Fetch the daily time spent data
  Future<List<double>> getDailyTimeSpent() async {
    if (_userId == null) return List.filled(7, 0.0);

    try {
      final DocumentSnapshot timeDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('gamification')
          .doc('timeSpent')
          .get();

      if (timeDoc.exists) {
        final data = timeDoc.data() as Map<String, dynamic>;
        final List<dynamic> dailyTime =
            data['dailyTime'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        final Timestamp? lastUpdated = data['lastUpdated'];

        if (lastUpdated != null) {
          DateTime lastUpdatedDate = lastUpdated.toDate();
          if (!_isSameWeek(lastUpdatedDate, DateTime.now())) {
            return List.filled(7, 0.0);
          }
        }

        return dailyTime.map((item) => (item as num).toDouble()).toList();
      }
    } catch (e) {
      print("Error fetching daily time spent: $e");
    }
    return List.filled(7, 0.0);
  }

  // Subscribe to real-time updates of daily time spent
  Stream<List<double>> streamDailyTimeSpent() {
    _userId = FirebaseAuth.instance.currentUser?.uid; // Refresh _userId
    if (_userId == null) {
      return Stream.value(List.filled(7, 0.0));
    }

    print("Streaming from: users/$_userId/gamification/timeSpent"); // Debug log
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('timeSpent')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final List<dynamic> dailyTime =
            data['dailyTime'] ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        List<double> timeList =
            dailyTime.map((item) => (item as num).toDouble()).toList();

        // Shift the list to align with current day as the last index
        final now = DateTime.now();
        final currentDayIndex = now.weekday - 1; // 0 (Mon) to 6 (Sun)
        List<double> shiftedTime = [];
        for (int i = 0; i < 7; i++) {
          int index = (currentDayIndex - 6 + i) % 7;
          if (index < 0) index += 7;
          shiftedTime.add(timeList[index]);
        }
        return shiftedTime;
      }
      return List.filled(7, 0.0);
    }).handleError((error) {
      print("Error streaming daily time spent: $error");
      return List.filled(7, 0.0);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _updateSessionTime();
    } else if (state == AppLifecycleState.resumed) {
      _startSessionTimer();
    }
  }

  // Clean up when the app is closed
  void dispose() {
    _sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
