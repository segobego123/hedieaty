import 'package:flutter/material.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatelessWidget {
  final List<Map<String, String>> events = [
    {"name": "John's Birthday", "date": "2024-12-05"},
    {"name": "Alice's Wedding", "date": "2024-12-15"},
  ];

  EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(event["name"]!),
              subtitle: Text("Date: ${event["date"]}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(eventName: event["name"]!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
