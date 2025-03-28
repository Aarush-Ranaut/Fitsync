import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataProvider with ChangeNotifier {
  String? _firstName;
  String? _lastName;
  String? _height;
  String? _weight;
  String? _age;
  DateTime? _birthDate;
  String? _selectedGender;
  String? _profilePicture;

  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get height => _height;
  String? get weight => _weight;
  String? get age => _age;
  DateTime? get birthDate => _birthDate;
  String? get selectedGender => _selectedGender;
  String? get profilePicture => _profilePicture;

  void updateUserData(Map<String, dynamic> data) {
    _firstName = data['firstName'];
    _lastName = data['lastName'];
    _height = data['height'].toString();
    _weight = data['weight'].toString();
    _age = data['age'].toString();
    if (data['birthDate'] != null) {
      _birthDate = DateTime.parse(data['birthDate']);
    }
    _selectedGender = data['gender'];
    _profilePicture = data['profileImage'];

    notifyListeners();
  }
}
