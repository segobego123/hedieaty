import 'package:flutter/material.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [
    {
      "name": "John's Birthday",
      "category": "Birthday",
      "status": "Upcoming",
      "date": DateTime(2024, 12, 1),
    },
    {
      "name": "Office Party",
      "category": "Work",
      "status": "Current",
      "date": DateTime(2024, 11, 25),
    },
    {
      "name": "Anniversary Celebration",
      "category": "Anniversary",
      "status": "Past",
      "date": DateTime(2024, 10, 10),
    },
  ];

  String _sortCriteria = "name";

  void _sortEvents() {
    setState(() {
      switch (_sortCriteria) {
        case "name":
          events.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case "category":
          events.sort((a, b) => a['category'].compareTo(b['category']));
          break;
        case "status":
          const statusOrder = {"Upcoming": 0, "Current": 1, "Past": 2};
          events.sort((a, b) => statusOrder[a['status']]!.compareTo(statusOrder[b['status']]!));
          break;
        default:
          break;
      }
    });
  }

  void _addEvent() {
    // Logic to add a new event
    print("Add event logic here");
  }

  void _editEvent(Map<String, dynamic> event) {
    // Logic to edit an event
    print("Edit event logic for ${event['name']}");
  }

  void _deleteEvent(Map<String, dynamic> event) {
    setState(() {
      events.remove(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event List"),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _sortCriteria = value;
              _sortEvents();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "name", child: Text("Sort by Name")),
              const PopupMenuItem(value: "category", child: Text("Sort by Category")),
              const PopupMenuItem(value: "status", child: Text("Sort by Status")),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(event['name']),
              subtitle: Text("Category: ${event['category']}\nStatus: ${event['status']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editEvent(event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEvent(event),
                  ),
                ],
              ),
              onTap: () {
                // Optional: Navigate to detailed event page
                print("Tapped on ${event['name']}");
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: Colors.deepOrangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
