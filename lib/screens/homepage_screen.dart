import 'package:flutter/material.dart';

import 'addfriend_screen.dart';
import 'eventlistpage_screen.dart';
import 'giftlistpage_screen.dart';
import 'createeventlist_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<Map<String, dynamic>> friends = [
    {
      "name": "John Doe",
      "profilePic": "images/john doe.jpg", // Add your image assets here
      "upcomingEvents": 1
    },
    {
      "name": "Jane Doe",
      "profilePic": "images/jane doe.jpg",
      "upcomingEvents": 0
    },
  ];

  void navigateToGiftList(String friendName) {
    // Navigate to the Gift List Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(friendName: friendName, eventName: '',),
      ),
    );
  }

  void navigateToEventList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EventListPage(),
      ),
    );
  }

  void addFriend() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFriendPage(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      print("Friend added: ${result['name']} - ${result['phone']}");
      // Add result to your friend list
    }
  }


  void createEventOrList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventListPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      print("Event/List created: $result");
      // Add result to your events/lists
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        toolbarHeight: 50,
        title: Text(
          "Hedieaty",
        style: TextStyle(color: Colors.white),
        ),
          centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: createEventOrList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Create Your Own Event/List",
                  style: TextStyle(color: Colors.white)
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: navigateToEventList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("View Event List",
                  style: TextStyle(color: Colors.white)
                  ),
                ),
              ),
          ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(friend['profilePic']),
                    ),
                    title: Text(friend["name"]),
                    subtitle: Text(friend["upcomingEvents"] > 0
                        ?"Upcoming Events: ${friend['upcomingEvents']}"
                        :"No Upcoming Events"),
                    trailing: Icon(
                      friend["upcomingEvents"] > 0
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: friend['upcomingEvents'] > 0 ? Colors.green :Colors.grey,
                    ),
                    onTap: () => navigateToGiftList(friend['name']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addFriend,
          backgroundColor: Colors.deepOrangeAccent,
          child: const Icon(Icons.person_add),
      ),
    );
  }
}

