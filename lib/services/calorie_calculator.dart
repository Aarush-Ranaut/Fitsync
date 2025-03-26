// import 'package:cloud_firestore/cloud_firestore.dart';

// class CalorieCalculator {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Fetches user's BMR and weight from Firestore
//   Future<Map<String, dynamic>?> fetchUserData(String userId) async {
//     try {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(userId).get();

//       if (!userDoc.exists) {
//         print("User data not found");
//         return null;
//       }

//       Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

//       if (userData == null) {
//         print("User data is null");
//         return null;
//       }

//       int? weight = userData['weight'];
//       int? height = userData['height'];
//       int? age = userData['age'];
//       String? gender = userData['gender'];

//       if (weight == null || height == null || age == null || gender == null) {
//         print("Missing required data for calorie calculation.");
//         return null;
//       }

//       double bmr;
//       if (gender.toLowerCase() == 'male') {
//         bmr = 10 * weight + 6.25 * height - 5 * age + 5;
//       } else if (gender.toLowerCase() == 'female') {
//         bmr = 10 * weight + 6.25 * height - 5 * age - 161;
//       } else {
//         print("Invalid gender data");
//         return null;
//       }

//       return {
//         'bmr': bmr,
//         'weight': weight.toDouble(), // Convert to double for consistency
//       };
//     } catch (e) {
//       print("Error fetching user data: $e");
//       return null;
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalorieCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the authenticated user's BMR and weight from Firestore.
  // Modified fetchUserData method
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Parse birth date from Firestore
      DateTime? birthDate;
      if (data['birthDate'] != null) {
        if (data['birthDate'] is Timestamp) {
          birthDate = (data['birthDate'] as Timestamp).toDate();
        } else {
          birthDate = DateTime.parse(data['birthDate'].toString());
        }
      }

      // Calculate age from birth date
      int age = 0;
      if (birthDate != null) {
        final now = DateTime.now();
        age = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
      }

      // Rest of the data parsing
      double weight = _safeConvertToDouble(data['weight']);
      double height = _safeConvertToDouble(data['height']);
      String gender = data['gender']?.toString().toLowerCase() ?? '';

      if (weight <= 0 || height <= 0 || age <= 0 || gender.isEmpty) {
        print(
            "Invalid data - Weight: $weight, Height: $height, Age: $age, Gender: $gender");
        return null;
      }

      // BMR Calculation
      double bmr = gender == 'male'
          ? 10 * weight + 6.25 * height - 5 * age + 5
          : 10 * weight + 6.25 * height - 5 * age - 161;

      return {'bmr': bmr, 'weight': weight, 'age': age};
    } catch (e) {
      print("Error in fetchUserData: $e");
      return null;
    }
  }

  double _safeConvertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _safeConvertToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Stores maintenance calorie data securely in Firestore under the authenticated user's document.
  Future<void> storeMaintenanceData(
      double maintenance, double gain, double loss) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("User is not authenticated");
        return;
      }

      String userId = user.uid;

      // Store data in the "maintenance_data" subcollection with a fixed document ID.
      DocumentReference maintenanceDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('maintenance_data')
          .doc('maintenance'); // Fixed document ID for compliance with rules

      await maintenanceDoc.set({
        'maintenanceCalories': maintenance,
        'weightGainCalories': gain,
        'weightLossCalories': loss,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge to avoid overwriting existing fields

      print("Maintenance data saved successfully!");
    } catch (e) {
      print("Error storing maintenance data: $e");
    }
  }
}
