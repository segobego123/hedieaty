import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> gift;
  final String giftId; // Firestore gift document ID
  final String eventId; // Firestore event document ID

  const GiftDetailsScreen({
    super.key,
    required this.gift,
    required this.giftId,
    required this.eventId,
  });

  void _pledgeGift(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to pledge a gift.')),
      );
      return;
    }

    final userId = user.uid;
    final now = DateTime.now();

    try {
      // Step 1: Update gift status
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({'status': 'Pledged'});

      // Step 2: Add to user's pledged_gifts
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pledged_gifts')
          .add({
        'giftName': gift['name'] ?? 'Unnamed Gift',
        'eventDate': gift['dueDate'] ?? 'No Date',
        'friendId': gift['friendId'] ?? 'Unknown',
        'pledgedAt': now.toIso8601String(),
        'eventId': eventId,
        'giftId': giftId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift pledged successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pledge gift: $error')),
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
            if (gift.containsKey("price"))
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
