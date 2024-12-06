

import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Map<String, dynamic>> pledgedGifts = [
    {
      "giftName": "Laptop",
      "friendName": "Alice",
      "dueDate": "2024-12-01",
      "status": "Pending",
    },
    {
      "giftName": "Cookbook",
      "friendName": "Bob",
      "dueDate": "2024-11-30",
      "status": "Completed",
    },
  ];

  MyPledgedGiftsPage({super.key});

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
              title: Text(gift["giftName"]),
              subtitle: Text(
                "For: ${gift["friendName"]}\nDue: ${gift["dueDate"]}",
                style: const TextStyle(height: 1.5),
              ),
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
