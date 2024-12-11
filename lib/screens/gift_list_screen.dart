import 'package:flutter/material.dart';
import 'gift_details_screen.dart';

class GiftListScreen extends StatelessWidget {
  final String eventName;
  final List<Map<String, String>> gifts = [
    {"name": "Smartphone", "status": "Available"},
    {"name": "Wristwatch", "status": "Pledged"},
  ];

  GiftListScreen({super.key, required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$eventName - Gifts'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(gift["name"]!),
              subtitle: Text('Status: ${gift["status"]}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GiftDetailsScreen(gift: gift),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
