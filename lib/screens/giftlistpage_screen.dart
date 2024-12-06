import 'package:flutter/material.dart';
import 'giftdetailspage_screen.dart';

class GiftListPage extends StatefulWidget {
  final String eventName; // Name of the event for the gift list

  const GiftListPage({super.key, required this.eventName, required String friendName});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> gifts = [
    {"name": "Laptop", "category": "Electronics", "price": 1000, "isPledged": false},
    {"name": "Cookbook", "category": "Books", "price": 20, "isPledged": true},
  ];

  String _sortCriteria = "name";

  void sortGifts(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (criteria == "name") {
        gifts.sort((a, b) => a["name"].compareTo(b["name"]));
      } else if (criteria == "category") {
        gifts.sort((a, b) => a["category"].compareTo(b["category"]));
      } else if (criteria == "status") {
        gifts.sort((a, b) => a["isPledged"].toString().compareTo(b["isPledged"].toString()));
      }
    });
  }

  void addGift(Map<String, dynamic> newGift) {
    setState(() {
      gifts.add(newGift);
    });
  }

  void editGift(int index, Map<String, dynamic> updatedGift) {
    setState(() {
      gifts[index] = updatedGift;
    });
  }

  void deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  void navigateToGiftDetailsPage({Map<String, dynamic>? gift, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(
          gift: gift,
          isEditing: gift != null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (index != null) {
        editGift(index, result);
      } else {
        addGift(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName} - Gift List"),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: sortGifts,
            itemBuilder: (context) => [
              const PopupMenuItem(value: "name", child: Text("Sort by Name")),
              const PopupMenuItem(value: "category", child: Text("Sort by Category")),
              const PopupMenuItem(value: "status", child: Text("Sort by Status")),
            ],
          ),
        ],
      ),
      body: gifts.isEmpty
          ? const Center(child: Text("No gifts added yet."))
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: gift["isPledged"] ? Colors.green[100] : null,
            child: ListTile(
              title: Text(gift["name"]),
              subtitle: Text("${gift["category"]} - \$${gift["price"]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: gift["isPledged"]
                        ? null
                        : () => navigateToGiftDetailsPage(gift: gift, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: gift["isPledged"]
                        ? null
                        : () => deleteGift(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToGiftDetailsPage(),
        backgroundColor: Colors.deepOrangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
