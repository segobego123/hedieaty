import 'package:flutter/material.dart';
import 'gift_details_screen.dart';

class FriendSpecificScreen extends StatelessWidget {
  final String friendName;
  final List<Map<String, String>> friendGifts = [
    {"name": "Book", "status": "Available"},
    {"name": "Camera", "status": "Pledged"},
  ];

  FriendSpecificScreen({super.key, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$friendName's Gifts"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        itemCount: friendGifts.length,
        itemBuilder: (context, index) {
          final gift = friendGifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(gift["name"]!),
              subtitle: Text("Status: ${gift["status"]}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GiftDetailsScreen(gift: gift, giftId: '', eventId: '',),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
