import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gift_details_screen.dart';

class FriendSpecificPage extends StatelessWidget {
  final String friendId;
  final String friendName;

  FriendSpecificPage({super.key, required this.friendId, required this.friendName});

  @override
  Widget build(BuildContext context) {
    final giftsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .collection('gifts');  // Assuming gifts are stored under each friend in Firestore

    return Scaffold(
      appBar: AppBar(
        title: Text("$friendName's Gifts"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: giftsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading gifts'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No gifts found.'));
          }

          final friendGifts = snapshot.data!.docs.map((doc) {
            return {
              'name': doc['name'],
              'status': doc['status'],
            };
          }).toList();

          return ListView.builder(
            itemCount: friendGifts.length,
            itemBuilder: (context, index) {
              final gift = friendGifts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(gift['name']),
                  subtitle: Text("Status: ${gift['status']}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GiftDetailsScreen(
                        gift: gift,
                        giftId: gift['name'],  // Assuming 'name' is unique for now
                        eventId: '', // You can dynamically pass eventId if needed
                      ),
                    ),
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
