import 'package:flutter/material.dart';

class ProfilePageScreen extends StatelessWidget {
  // Mock user information
  final Map<String, String> userInfo = {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
  };

  // Mock list of events
  final List<Map<String, dynamic>> userEvents = [
    {"eventName": "John's Birthday", "gifts": 5, "friendName": "You"},
    {"eventName": "Alice's Wedding", "gifts": 2, "friendName": "Alice"},
    {"eventName": "Team Outing", "gifts": 3, "friendName": "Bob"},
  ];

  ProfilePageScreen({super.key});

  // Navigate to the Gift List Page
  void navigateToEventGifts(BuildContext context, String eventName, String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(eventName: eventName, friendName: friendName),
      ),
    );
  }

  // Navigate to My Pledged Gifts Page
  void navigateToPledgedGifts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyPledgedGiftsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Information Section
          const Text(
            "User Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.deepOrangeAccent),
            title: Text(userInfo["name"]!),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.deepOrangeAccent),
            title: Text(userInfo["email"]!),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.deepOrangeAccent),
            title: Text(userInfo["phone"]!),
          ),
          const Divider(thickness: 1, height: 32),
          // My Events Section
          const Text(
            "My Events",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...userEvents.map(
                (event) => ListTile(
              title: Text(event["eventName"]),
              subtitle: Text("Gifts: ${event["gifts"]}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => navigateToEventGifts(context, event["eventName"], event["friendName"]),
            ),
          ),
          const Divider(thickness: 1, height: 32),
          // Navigate to Pledged Gifts Page
          ElevatedButton(
            onPressed: () => navigateToPledgedGifts(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("View My Pledged Gifts"),
          ),
        ],
      ),
    );
  }
}

// Mock GiftListPage
class GiftListPage extends StatelessWidget {
  final String eventName;
  final String friendName;

  const GiftListPage({super.key, required this.eventName, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friendName == "You" ? "$eventName - Gifts" : "$friendName's Event Gifts"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Center(
        child: Text("Gifts for $eventName (Owner: $friendName)"),
      ),
    );
  }
}

// Mock MyPledgedGiftsPage
class MyPledgedGiftsPage extends StatelessWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: const Center(
        child: Text("List of pledged gifts will appear here."),
      ),
    );
  }
}
