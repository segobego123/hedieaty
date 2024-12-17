import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyPledgedGiftsScreen extends StatefulWidget {
  const MyPledgedGiftsScreen({super.key});

  @override
  _MyPledgedGiftsScreenState createState() => _MyPledgedGiftsScreenState();
}

class _MyPledgedGiftsScreenState extends State<MyPledgedGiftsScreen> {
  Future<List<Map<String, dynamic>>> _fetchPledgedGifts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return [];
    }

    try {
      // Fetch pledged gifts
      final pledgedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pledged_gifts')
          .get();

      List<Map<String, dynamic>> gifts = [];

      for (var doc in pledgedSnapshot.docs) {
        final data = doc.data();
        final eventId = data['eventId'];
        final giftId = data['giftId'];

        // Fetch event details
        String eventDate = "No Date";
        String friendId = "Unknown";
        String friendName = "Unknown";

        if (eventId != null && giftId != null) {
          final eventSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();

          if (eventSnapshot.exists) {
            final eventData = eventSnapshot.data();
            eventDate = eventData?['date'] ?? "No Date";
            friendId = eventData?['userId'] ?? "Unknown";

            // Fetch friend (event creator) name
            final friendSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .get();

            if (friendSnapshot.exists) {
              friendName = friendSnapshot.data()?["name"] ?? "Unknown Friend";
            }
          }
        }

        // Add gift details
        gifts.add({
          "id": doc.id,
          "name": data["giftName"] ?? "Unnamed Gift",
          "friendName": friendName,
          "dueDate": eventDate,
          "eventId": eventId,
          "giftId": giftId,
        });
      }

      return gifts;
    } catch (e) {
      debugPrint("Error fetching pledged gifts: $e");
      return [];
    }
  }

  Future<void> _unpledgeGift(String eventId, String giftId, String pledgedGiftDocId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      // Step 1: Update gift status back to "Available"
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({"status": "Available"});

      // Step 2: Remove the gift from pledged_gifts
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pledged_gifts')
          .doc(pledgedGiftDocId)
          .delete();

      // Step 3: Show confirmation and refresh screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift unpledged successfully')),
      );
      setState(() {});
    } catch (e) {
      debugPrint("Error unpledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unpledge gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No pledged gifts yet."));
          }

          final pledgedGifts = snapshot.data!;

          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(gift["name"]),
                  subtitle: Text(
                    "For: ${gift["friendName"]}\nDue: ${gift["dueDate"] != null ? DateFormat.yMMMMd().format(DateTime.parse(gift["dueDate"])) : "No Date"}",
                  ),

                  trailing: ElevatedButton(
                    onPressed: () {
                      _unpledgeGift(
                        gift["eventId"],
                        gift["giftId"],
                        gift["id"],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text("Unpledge"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
