import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> gift;
  final String giftId; // Pass the Firestore gift document ID.
  final String eventId; // Pass the Firestore event document ID.

  const GiftDetailsScreen({
    super.key,
    required this.gift,
    required this.giftId,
    required this.eventId,
  });

  void _pledgeGift(BuildContext context) async {
    try {
      // Update the status field in Firestore.
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({'status': 'Pledged'});

      // Show confirmation message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift status updated to Pledged!')),
      );

      // Optionally, navigate back or refresh the screen.
      Navigator.pop(context);
    } catch (error) {
      // Show error message if update fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update gift status: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gift["name"] ?? "Gift Details"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gift["name"] ?? "Unnamed Gift",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Status: ${gift["status"] ?? "Unknown"}"),
            const SizedBox(height: 10),
            if (gift.containsKey("price")) // Check if price exists.
              Text("Price: \$${gift["price"] ?? "N/A"}"),
            const SizedBox(height: 20),
            const Text(
              "Gift Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Description: ${gift["description"] ?? "No description available."}"),
            const SizedBox(height: 10),
            Text("Category: ${gift["category"] ?? "Uncategorized"}"),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _pledgeGift(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
              child: const Text("Pledge This Gift"),
            ),
          ],
        ),
      ),
    );
  }
}
