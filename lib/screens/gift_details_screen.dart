import 'package:flutter/material.dart';

class GiftDetailsScreen extends StatelessWidget {
  final Map<String, String> gift;

  const GiftDetailsScreen({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gift["name"]!),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gift["name"]!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Status: ${gift["status"]}"),
            const SizedBox(height: 20),
            const Text(
              "Gift Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Description: High-quality gift perfect for any occasion."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to pledge or modify gift status
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
              child: const Text("Pledge This Gift"),
            ),
          ],
        ),
      ),
    );
  }
}
