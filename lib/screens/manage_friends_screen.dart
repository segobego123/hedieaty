import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFriendsScreen extends StatefulWidget {
  const ManageFriendsScreen({super.key});

  @override
  State<ManageFriendsScreen> createState() => _ManageFriendsScreenState();
}

class _ManageFriendsScreenState extends State<ManageFriendsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final String currentUserId = 'dummy_user_id'; // Replace with FirebaseAuth user ID

  Future<void> _addFriend(String friendEmail) async {
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

    // Add friend to the friend list
    await FirebaseFirestore.instance.collection('friends').add({
      'userId': currentUserId,
      'friendId': friendId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Friends'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
          ],
        ),
      ),
    );
  }
}
