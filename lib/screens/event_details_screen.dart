import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gift_list_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId; // Use eventId to fetch details from Firestore.

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading event details'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Event not found'));
          }

          final event = snapshot.data!.data() as Map<String, dynamic>;
          final eventName = event['name'] ?? 'Unnamed Event';
          final eventDate = event['date'] ?? 'No date provided';
          final eventLocation = event['location'] ?? 'No location specified';
          final eventDescription = event['description'] ?? 'No description available';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Event Date'),
                  subtitle: Text(eventDate),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_pin),
                  title: const Text('Event Location'),
                  subtitle: Text(eventLocation),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Event Description'),
                  subtitle: Text(eventDescription),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GiftListScreen(eventId: eventId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
                    child: const Text('View Gifts'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
