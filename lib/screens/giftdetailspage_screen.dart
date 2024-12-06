import 'package:flutter/material.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? gift;
  final bool isEditing;

  const GiftDetailsPage({super.key, this.gift, required this.isEditing});

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = ["Electronics", "Books", "Clothing", "Toys"];

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      _nameController.text = widget.gift!["name"];
      _descriptionController.text = widget.gift!["description"] ?? "";
      _priceController.text = widget.gift!["price"].toString();
      _selectedCategory = widget.gift!["category"];
    }
  }

  void saveGift() {
    if (_formKey.currentState!.validate()) {
      final newGift = {
        "name": _nameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "category": _selectedCategory ?? "Uncategorized",
        "price": double.parse(_priceController.text),
        "isPledged": widget.gift?["isPledged"] ?? false,
      };
      Navigator.pop(context, newGift);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPledged = widget.gift?["isPledged"] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Gift" : "Add Gift"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Gift Name"),
                validator: (value) => value == null || value.trim().isEmpty ? "Enter a gift name" : null,
                enabled: !isPledged,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: isPledged ? null : (value) => setState(() => _selectedCategory = value),
                decoration: const InputDecoration(labelText: "Category"),
                validator: (value) => value == null ? "Select a category" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null ? "Enter a valid price" : null,
                enabled: !isPledged,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description (Optional)"),
                maxLines: 3,
                enabled: !isPledged,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isPledged ? null : saveGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(widget.isEditing ? "Save Changes" : "Add Gift"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
