import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'gender_selection.dart'; // Import the GenderSelectionScreen

class ProfileScreen extends StatefulWidget {
  final String userId; // Use userId instead of userEmail

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profilePicture; // For base64 encoded profile picture
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _birthDate; // To store the selected birth date

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .get(); // Use userId

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        if (data['profileImage'] != null && data['profileImage'].isNotEmpty) {
          setState(() {
            _profilePicture = data['profileImage'];
          });
        }
        if (data['birthDate'] != null) {
          setState(() {
            _birthDate = DateTime.parse(data['birthDate']);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profilePicture = base64Encode(bytes);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    // Calculate the latest date allowed (3 years before today)
    final DateTime today = DateTime.now();
    final DateTime minAgeDate =
        DateTime(today.year - 3, today.month, today.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? minAgeDate,
      firstDate: DateTime(1900), // Earliest possible date
      lastDate: minAgeDate, // Latest date ensuring age >= 3
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Double-check the age requirement (in case of edge cases)
      final int age = today.year -
          pickedDate.year -
          ((today.month < pickedDate.month ||
                  (today.month == pickedDate.month &&
                      today.day < pickedDate.day))
              ? 1
              : 0);

      if (age < 3) {
        _showAgeRestrictionDialog();
      } else {
        setState(() {
          _birthDate = pickedDate;
        });
      }
    }
  }

  void _showAgeRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Age Restriction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "You must be at least 3 years old to use this app. Please select a birth date that meets this requirement.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveData() async {
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First name and last name are required")),
      );
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your birth date")),
      );
      return;
    }

    // Verify age one last time before saving
    final DateTime today = DateTime.now();
    final int age = today.year -
        _birthDate!.year -
        ((today.month < _birthDate!.month ||
                (today.month == _birthDate!.month &&
                    today.day < _birthDate!.day))
            ? 1
            : 0);

    if (age < 3) {
      _showAgeRestrictionDialog();
      return;
    }

    try {
      await _firestore.collection('users').doc(widget.userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'profileImage': _profilePicture ?? '',
        'birthDate': _birthDate!.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully")),
      );

      // Redirect to GenderSelectionScreen after saving
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GenderSelectionScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  void _showImageInFullScreen() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: CircleAvatar(
                radius: 120,
                backgroundImage: _profilePicture != null
                    ? MemoryImage(base64Decode(_profilePicture!))
                    : null,
                child: _profilePicture == null
                    ? const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showImageInFullScreen,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: _profilePicture != null
                            ? MemoryImage(base64Decode(_profilePicture!))
                            : null,
                        child: _profilePicture == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.green,
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Birth Date (Min. age: 3)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText:
                            'Select a date (must be at least 3 years old)',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                        ),
                      ),
                      controller: TextEditingController(
                        text: _birthDate != null
                            ? "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}"
                            : '',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
