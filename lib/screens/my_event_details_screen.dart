import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyEventDetailsScreen extends StatefulWidget {
  final String eventId;

  const MyEventDetailsScreen({super.key, required this.eventId});

  @override
  _MyEventDetailsScreenState createState() => _MyEventDetailsScreenState();
}

class _MyEventDetailsScreenState extends State<MyEventDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  bool _isLoading = true;
  DateTime? _selectedEventDate;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        final eventData = eventDoc.data()!;
        _nameController = TextEditingController(text: eventData['name']);
        _dateController = TextEditingController(text: eventData['date']);
        _locationController = TextEditingController(text: eventData['location']);
        _descriptionController = TextEditingController(text: eventData['description']);
        _selectedEventDate = DateTime.parse(eventData['date']);
      } else {
        _nameController = TextEditingController();
        _dateController = TextEditingController();
        _locationController = TextEditingController();
        _descriptionController = TextEditingController();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        // Store the date in ISO 8601 format: "yyyy-MM-ddTHH:mm:ss.SSS"
        _dateController.text = pickedDate.toIso8601String();
      });
    }
  }

  Future<void> _saveEventDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'name': _nameController.text,
          'date': _dateController.text, // Save the date as ISO string
          'location': _locationController.text,
          'description': _descriptionController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully')),
        );
        Navigator.pop(context); // Go back to the event list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectEventDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Event Location'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Event Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveEventDetails,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
