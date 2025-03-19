import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches user's BMR and weight from Firestore
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("User data not found");
        return null;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        print("User data is null");
        return null;
      }

      int? weight = userData['weight'];
      int? height = userData['height'];
      int? age = userData['age'];
      String? gender = userData['gender'];

      if (weight == null || height == null || age == null || gender == null) {
        print("Missing required data for calorie calculation.");
        return null;
      }

      double bmr;
      if (gender.toLowerCase() == 'male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else if (gender.toLowerCase() == 'female') {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      } else {
        print("Invalid gender data");
        return null;
      }

      return {
        'bmr': bmr,
        'weight': weight.toDouble(), // Convert to double for consistency
      };
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}
