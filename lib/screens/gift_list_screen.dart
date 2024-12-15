import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gift_details_screen.dart';

class GiftListScreen extends StatelessWidget {
  final String eventId; // Use eventId to locate the gifts subcollection.

  const GiftListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Gifts'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('gifts') // Access the gifts subcollection
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading gifts'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No gifts available for this event'));
          }

          final gifts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(gift['name'] ?? 'Unnamed Gift'),
                  subtitle: Text('Status: ${gift['status'] ?? 'Unknown'}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GiftDetailsScreen(giftId: gifts[index].id, eventId: eventId,
                        gift: {
                          "name": gift['name'] ?? 'Unnamed Gift',
                          "description": gift['description'] ?? 'No description available',
                          "category": gift['category'] ?? 'Uncategorized',
                          "price": gift['price']?.toString() ?? '0',
                          "status": gift['status'] ?? 'Unknown',
                        },
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
