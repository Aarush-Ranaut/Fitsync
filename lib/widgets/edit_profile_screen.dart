import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../widgets/home_screen.dart'; // Import the HomeScreen

class EditProfileScreen extends StatefulWidget {
  final String userId; // Use userId instead of userEmail

  const EditProfileScreen({super.key, required this.userId});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _profilePicture; // For base64 encoded profile picture
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  DateTime? _birthDate; // To store the selected birth date
  String? _selectedGender; // For dropdown gender selection

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _validGenders = [
    'Male',
    'Female',
    'Other'
  ]; // Valid gender options

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
        _heightController.text = data['height']?.toString() ?? '';
        _weightController.text = data['weight']?.toString() ?? '';

        // Only set _selectedGender if it matches a valid option, otherwise null
        String? fetchedGender = data['gender'];
        if (fetchedGender != null && _validGenders.contains(fetchedGender)) {
          _selectedGender = fetchedGender;
        } else {
          _selectedGender = null; // Default to null if invalid or empty
        }

        if (data['birthDate'] != null) {
          setState(() {
            _birthDate = DateTime.parse(data['birthDate']);
            _ageController.text = _calculateAge(_birthDate!).toString();
          });
        }
        if (data['profileImage'] != null && data['profileImage'].isNotEmpty) {
          setState(() {
            _profilePicture = data['profileImage'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
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
    final DateTime today = DateTime.now();
    final DateTime minAgeDate =
        DateTime(today.year - 3, today.month, today.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? minAgeDate,
      firstDate: DateTime(1900),
      lastDate: minAgeDate,
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
      final int age = _calculateAge(pickedDate);
      if (age < 3) {
        _showAgeRestrictionDialog();
      } else {
        setState(() {
          _birthDate = pickedDate;
          _ageController.text = age.toString();
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
    final String height = _heightController.text.trim();
    final String weight = _weightController.text.trim();
    final String age = _ageController.text.trim();
    final String? gender = _selectedGender;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        age.isEmpty ||
        _birthDate == null ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final int? parsedHeight = int.tryParse(height);
    if (parsedHeight == null || parsedHeight < 30 || parsedHeight > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Height must be between 30 and 250 cm")),
      );
      return;
    }

    final double? parsedWeight = double.tryParse(weight);
    if (parsedWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid weight format")),
      );
      return;
    }

    final int parsedAge = int.parse(age);
    if (parsedAge < 3) {
      _showAgeRestrictionDialog();
      return;
    }

    try {
      await _firestore.collection('users').doc(widget.userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'height': parsedHeight,
        'weight': parsedWeight,
        'age': parsedAge,
        'birthDate': _birthDate!.toIso8601String(),
        'profileImage': _profilePicture ?? '',
        'gender': gender,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
          "Edit Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _heightController,
                label: 'Height (30-250 cm)',
                keyboardType: TextInputType.number,
                inputFormatters: [HeightTextInputFormatter()],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [DecimalTextInputFormatter()],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickBirthDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: TextEditingController(
                      text: _birthDate != null
                          ? "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}"
                          : '',
                    ),
                    label: 'Birth Date (Min. age: 3)',
                    suffixIcon:
                        const Icon(Icons.calendar_today, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                readOnly: true,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: _buildInputDecoration(label: 'Gender'),
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: _validGenders.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
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
                    elevation: 5,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      decoration: _buildInputDecoration(label: label, suffixIcon: suffixIcon),
      style: const TextStyle(color: Colors.white),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[900],
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final RegExp regExp = RegExp(r'^\d*\.?\d{0,1}$');
    return regExp.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class HeightTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final RegExp digitOnlyRegExp = RegExp(r'^\d+$');
    if (!digitOnlyRegExp.hasMatch(newValue.text)) {
      return oldValue;
    }
    return newValue;
  }
}
