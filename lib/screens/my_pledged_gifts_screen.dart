import 'package:flutter/material.dart';

class MyPledgedGiftsScreen extends StatelessWidget {
  final List<Map<String, String>> pledgedGifts = [
    {"name": "Smartphone", "friendName": "Alice", "dueDate": "2024-12-01", "status": "Pending"},
    {"name": "Wristwatch", "friendName": "John", "dueDate": "2024-11-30", "status": "Completed"},
  ];

  MyPledgedGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: pledgedGifts.isEmpty
          ? const Center(child: Text("No pledged gifts yet."))
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(gift["name"]!),
              subtitle: Text("For: ${gift["friendName"]}\nDue: ${gift["dueDate"]}"),
              trailing: gift["status"] == "Pending"
                  ? ElevatedButton(
                onPressed: () {
                  // Implement modification logic for pending gifts
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                child: const Text("Modify"),
              )
                  : const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
