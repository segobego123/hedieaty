import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friend_specific_page_screen.dart';

class ManageFriendsScreen extends StatefulWidget {
  const ManageFriendsScreen({super.key});

  @override
  State<ManageFriendsScreen> createState() => _ManageFriendsScreenState();
}

class _ManageFriendsScreenState extends State<ManageFriendsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  /// Add a friend by email
  Future<void> _addFriend(String friendEmail) async {
    try {
      // Find the friend's user document by email
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      final friendId = userSnapshot.docs.first.id;

      // Check if the friend already exists in the subcollection
      final friendsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends');

      final existingFriendSnapshot = await friendsRef
          .where('friendId', isEqualTo: friendId)
          .get();

      if (existingFriendSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend already added')),
        );
        return;
      }

      // Add friend to the subcollection
      await friendsRef.add({
        'friendId': friendId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully')),
      );

      // Clear input field
      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    }
  }

  /// Remove a friend by document ID
  Future<void> _removeFriend(String friendDocId) async {
    try {
      // Delete the friend document from the subcollection
      final friendsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends');

      await friendsRef.doc(friendDocId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Friends'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Enter friend\'s email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addFriend(_emailController.text.trim()),
              child: const Text('Add Friend'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: friendsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading friends'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No friends added yet.'));
                  }

                  final friendDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: friendDocs.length,
                    itemBuilder: (context, index) {
                      final friendDoc = friendDocs[index];
                      final friendId = friendDoc['friendId'];

                      // Fetch friend details from users collection
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(friendId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading...'));
                          }

                          if (userSnapshot.hasError || !userSnapshot.hasData) {
                            return const ListTile(
                              title: Text('Error loading friend'),
                            );
                          }

                          final friendData = userSnapshot.data!.data() as Map<String, dynamic>;
                          final friendName = friendData['name'] ?? 'Unknown User';
                          final friendEmail = friendData['email'] ?? '';

                          return ListTile(
                            title: Text(friendName),
                            subtitle: Text(friendEmail),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFriend(friendDoc.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendSpecificPage(
                                    friendId: friendId,
                                    friendName: friendName,

                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
