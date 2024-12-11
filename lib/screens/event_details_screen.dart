import 'package:flutter/material.dart';
import 'gift_list_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventName;

  const EventDetailsScreen({super.key, required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Event Date'),
            subtitle: const Text('2024-12-05'), // Example date
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_pin),
            title: const Text('Event Location'),
            subtitle: const Text('123 Celebration Lane'), // Example location
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GiftListScreen(eventName: eventName),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            child: const Text('View Gifts'),
          ),
        ],
      ),
    );
  }
}
