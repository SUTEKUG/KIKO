import 'package:flutter/material.dart';
import 'package:owner/services/owner_services.dart';

class AddFoodItemDialog extends StatefulWidget {
  final String restaurantId;

  const AddFoodItemDialog({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _AddFoodItemDialogState createState() => _AddFoodItemDialogState();
}

class _AddFoodItemDialogState extends State<AddFoodItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _ownerService = OwnerService();

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  Future<void> _addFoodItem() async {
    if (_formKey.currentState!.validate()) {
      await _ownerService.addFoodItem(
        widget.restaurantId,
        _foodNameController.text.trim(),
      );
      Navigator.of(context).pop(); // Close dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Food Item"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _foodNameController,
              decoration: const InputDecoration(labelText: "Food Name"),
              validator: (value) => value!.isEmpty ? "Enter a food name" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _addFoodItem,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
