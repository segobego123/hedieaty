import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_phase_1/services/database_service.dart'; // Import your DatabaseService

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> gifts = [];

  final DatabaseService _dbService = DatabaseService(); // Initialize DatabaseService

  Future<void> _saveEventToDatabase(String userId) async {
    try {
      // Insert event
      final eventId = await _dbService.insertEvent({
        'name': _nameController.text,
        'date': _dateController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'userId': userId,
      });

      // Insert gifts linked to the event
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

  Future<void> _publishEventToFirestore(String userId) async {
    try {
      // Fetch events from local database
      final events = await _dbService.getEvents(userId);

      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No events to publish')),
        );
        return;
      }

      for (var event in events) {
        // Upload event to Firestore
        final eventRef = await FirebaseFirestore.instance
            .collection('events')
            .add({
          'name': event['name'],
          'date': event['date'],
          'location': event['location'],
          'description': event['description'],
          'userId': userId,
        });

        // Fetch and upload associated gifts
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

        // Optionally delete from local database after publishing
        await _dbService.deleteEvent(event['id']);
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
    final userId = 'dummy_user_id'; // Replace with FirebaseAuth user ID

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
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Event Date'),
            ),
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
              onPressed: () => _saveEventToDatabase(userId),
              icon: const Icon(Icons.save),
              label: const Text('Save Locally'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _publishEventToFirestore(userId),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Publish Event'),
            ),
          ],
        ),
      ),
    );
  }
}
