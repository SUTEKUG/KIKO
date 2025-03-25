import 'package:flutter/material.dart';
import 'package:owner/services/owner_services.dart';
import 'package:owner/screens/menu/add_food_item_dialog.dart'; // Import the AddFoodItemDialog

class AddFoodPage extends StatefulWidget {
  final String restaurantId;

  const AddFoodPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _ownerService = OwnerService();

  Future<void> _showAddFoodDialog() async {
    await showDialog(
      context: context,
      builder: (context) =>
          AddFoodItemDialog(restaurantId: widget.restaurantId),
    );
    setState(() {}); // Refresh UI after adding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Food Items")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ownerService.getRestaurantFoodItems(widget.restaurantId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final foodItems = snapshot.data!;

          if (foodItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No food items yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddFoodDialog,
                    child: const Text('Add First Item'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final item = foodItems[index];
              return Dismissible(
                key: Key(item['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  try {
                    await _ownerService.removeFoodItem(item['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item removed')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: ListTile(
                  title: Text(item['food_name']),
                  trailing: const Icon(Icons.drag_handle),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _showAddFoodDialog,
          child: const Text("Add Food Item"),
        ),
      ),
    );
  }
}
