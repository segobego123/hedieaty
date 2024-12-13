import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page_screen.dart';
import 'event_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No user logged in')),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepOrangeAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.card_giftcard, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Gift Manager',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePageScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to Hedieaty!'),
      ),
    );
  }
}
