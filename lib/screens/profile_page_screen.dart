import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedBirthday; // Store birthday as DateTime
  final TextEditingController _jobController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = _auth.currentUser;

    if (_currentUser != null) {
      final userDoc =
      await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _jobController.text = userData['job'] ?? '';
        if (userData['birthday'] != null) {
          _selectedBirthday =
              (userData['birthday'] as Timestamp).toDate(); // Convert Firestore Timestamp to DateTime
        }
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_currentUser == null) return;

    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'birthday': _selectedBirthday, // Store birthday as DateTime
          'job': _jobController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900), // Earliest possible date
      lastDate: DateTime.now(), // Latest possible date
    );

    if (pickedDate != null && pickedDate != _selectedBirthday) {
      setState(() {
        _selectedBirthday = pickedDate;
      });
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // RegExp to validate the phone number format
    final phoneRegExp = RegExp(r'^01\d{9}$'); // Starts with '01' and has exactly 11 digits

    if (!phoneRegExp.hasMatch(value)) {
      return 'Enter a valid Egyptian phone number.';
    }

    return null; // No validation errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach the form key
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: true, // Email should typically not be editable
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone, // Keyboard optimized for numbers
                  validator: _validatePhone, // Add validation function
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedBirthday == null
                          ? 'Select Birthday'
                          : 'Birthday: ${DateFormat('yyyy-MM-dd').format(_selectedBirthday!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectBirthday(context),
                      child: const Text('Choose Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _jobController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateUserData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
