import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_details_screen.dart';
import 'package:intl/intl.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  /// Fetch friend IDs from the user's `friends` subcollection.
  Future<List<String>> _fetchFriendIds(String myUserId) async {
    try {
      // Access the friends subcollection for the user
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(myUserId)
          .collection('friends')
          .get();

      // Extract the `friendId` field from each document
      return friendsSnapshot.docs.map((doc) => doc['friendId'] as String).toList();
    } catch (e) {
      debugPrint("Error fetching friend IDs: $e");
      return [];
    }
  }

  /// Fetch events for a specific user ID.
  Future<List<DocumentSnapshot>> _fetchEventsForUser(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('events')
          //.where('userId', isEqualTo: userId)
          .orderBy('date') // Ensure you have an index on `userId` and `date`
          .get();

      return query.docs;
    } catch (e) {
      debugPrint("Error fetching events for user $userId: $e");
      return [];
    }
  }

  /// Fetch events for the current user and their friends, ensuring no duplicates.
  Future<List<DocumentSnapshot>> _fetchEvents(String myUserId) async {
    try {
      // Step 1: Fetch friend IDs
      final friendIds = await _fetchFriendIds(myUserId);

      // Step 2: Combine the user's ID with the friend IDs
      final allUserIds = [myUserId, ...friendIds];

      // Step 3: Fetch events for each user ID and merge them
      final List<DocumentSnapshot> allEvents = [];

      for (final userId in allUserIds) {
        final userEvents = await _fetchEventsForUser(userId);
        allEvents.addAll(userEvents);
      }

      // Step 4: Remove duplicate events based on eventId
      final seenEventIds = Set<String>(); // To track unique event IDs
      final uniqueEvents = allEvents.where((event) {
        final eventId = event.id;
        if (seenEventIds.contains(eventId)) {
          return false; // Skip duplicates
        } else {
          seenEventIds.add(eventId);
          return true; // Include this event
        }
      }).toList();

      return uniqueEvents;
    } catch (e) {
      debugPrint("Error fetching events: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String myUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchEvents(myUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading events.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final events = snapshot.data!;
          final today = DateTime.now();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              final eventName = event["name"] ?? "Unnamed Event";
              final eventDateStr = event["date"] ?? "No date provided";

              DateTime? eventDate;
              if (eventDateStr != "No date provided") {
                try {
                  eventDate = DateTime.parse(eventDateStr);
                } catch (_) {
                  debugPrint("Invalid date format for event: $eventDateStr");
                }
              }

              final isCompleted = eventDate != null && today.isAfter(eventDate);

              return Card(
                color: isCompleted ? Colors.green[100] : null, // Highlight completed events
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(eventName),
                  subtitle: Text("Date: ${eventDate != null ? DateFormat.yMMMMd().format(eventDate) : eventDateStr}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(
                          eventId: events[index].id,
                          isEditable: false, // Events are view-only in this context
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
