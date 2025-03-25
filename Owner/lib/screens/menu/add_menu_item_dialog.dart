import 'package:flutter/material.dart';
import 'package:owner/services/owner_services.dart';
import 'package:owner/widgets/custom_text_field.dart';

class AddMenuItemDialog extends StatefulWidget {
  final String restaurantId;

  const AddMenuItemDialog({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  _AddMenuItemDialogState createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ownerService = OwnerService();
  bool _isLoading = false;

  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _ownerService.addMenuItem(
          restaurantId: widget.restaurantId,
          name: _nameController.text,
          price: double.parse(_priceController.text),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Menu Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Item Name',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            CustomTextField(
              controller: _priceController,
              label: 'Price',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid price';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addItem,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Item'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
