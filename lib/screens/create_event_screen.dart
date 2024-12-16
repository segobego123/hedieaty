import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:project_phase_1/services/database_service.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedEventDate; // Store event date as DateTime
  final List<Map<String, String>> gifts = [];
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser; // Store the currently logged-in user

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser; // Get current Firebase user
    });
  }

  Future<void> _saveEventToDatabase() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      // Save event locally with the user's ID
      final eventId = await _dbService.insertEvent({
        'name': _nameController.text.trim(),
        'date': _selectedEventDate?.toIso8601String(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'userId': _currentUser!.uid, // Save the userId
      });

      // Save associated gifts to the database
      for (var gift in gifts) {
        await _dbService.insertGift({
          'name': gift['name']!,
          'description': gift['description']!,
          'category': gift['category']!,
          'price': double.parse(gift['price']!).toString(),
          'status': 'available',
          'eventId': eventId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved locally')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: $e')),
      );
    }
  }

  Future<void> _publishEventToFirestore() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final events = await _dbService.getEvents(_currentUser!.uid);

      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No events to publish')),
        );
        return;
      }

      for (var event in events) {
        // Publish event to Firestore
        final eventRef = await FirebaseFirestore.instance
            .collection('events')
            .add({
          'name': event['name'],
          'date': event['date'],
          'location': event['location'],
          'description': event['description'],
          'userId': event['userId'], // Include userId when publishing
        });

        // Publish associated gifts to Firestore
        final giftsData = await _dbService.getGifts(event['id']);
        for (var gift in giftsData) {
          await FirebaseFirestore.instance
              .collection('events')
              .doc(eventRef.id)
              .collection('gifts')
              .add({
            'name': gift['name'],
            'description': gift['description'],
            'category': gift['category'],
            'price': gift['price'],
            'status': gift['status'],
          });
        }

        // Optionally delete the event locally after publishing
        // await _dbService.deleteEvent(event['id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Events published to Firestore successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing events: $e')),
      );
    }
  }

  Future<void> _selectEventDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedEventDate) {
      setState(() {
        _selectedEventDate = pickedDate;
      });
    }
  }

  void _addGiftDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    gifts.add({
                      'name': nameController.text,
                      'description': descController.text,
                      'category': categoryController.text,
                      'price': priceController.text,
                    });
                  });
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedEventDate == null
                      ? 'Select Event Date'
                      : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedEventDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => _selectEventDate(context),
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addGiftDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Gift'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveEventToDatabase,
              icon: const Icon(Icons.save),
              label: const Text('Save Locally'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _publishEventToFirestore,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Publish Event'),
            ),
          ],
        ),
      ),
    );
  }
}
