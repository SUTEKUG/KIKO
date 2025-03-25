import 'package:flutter/material.dart';
import 'package:owner/screens/menu/add_menu_item_dialog.dart';
import 'package:owner/services/owner_services.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final _ownerService = OwnerService();

  Future<void> _showAddItemDialog(String restaurantId) async {
    await showDialog(
      context: context,
      builder: (context) => AddMenuItemDialog(restaurantId: restaurantId),
    );
    // Refresh the screen after adding an item
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _ownerService.getCurrentRestaurant(),
        builder: (context, restaurantSnapshot) {
          if (restaurantSnapshot.hasError) {
            return Center(child: Text('Error: ${restaurantSnapshot.error}'));
          }

          if (!restaurantSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final restaurantId = restaurantSnapshot.data!['id'];

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _ownerService.getRestaurantMenuItems(restaurantId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final menuItems = snapshot.data!;

              if (menuItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No menu items yet'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddItemDialog(restaurantId),
                        child: const Text('Add First Item'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
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
                        await _ownerService.removeMenuItem(item['id']);
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
                      title: Text(item['name']),
                      subtitle: Text('UGX ${item['price']}'),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final restaurant = await _ownerService.getCurrentRestaurant();
          if (mounted && restaurant != null) {
            _showAddItemDialog(restaurant['id']);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
