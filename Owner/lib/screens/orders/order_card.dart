import 'package:flutter/material.dart';
import 'package:owner/services/owner_services.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final _ownerService = OwnerService();

  OrderCard({Key? key, required this.order}) : super(key: key);

  Future<void> _updateStatus(BuildContext context, String status) async {
    try {
      await _ownerService.updateOrderStatus(
        orderId: order['id'],
        status: status,
        statusMessage: status == 'completed'
            ? 'Your order will arrive shortly'
            : 'Order is being prepared',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely access nested properties
    final menuItem = order['menu_items'] as Map<String, dynamic>?;
    final customer = order['new_profiles'] as Map<String, dynamic>?;

    if (menuItem == null || customer == null) {
      return const SizedBox.shrink(); // Skip rendering if data is missing
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['id'].toString().substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusChip(order['status'] ?? 'pending'),
              ],
            ),
            const Divider(),
            Text('Item: ${menuItem['name'] ?? 'N/A'}'),
            Text('Quantity: ${order['quantity'] ?? 0}'),
            Text(
                'Total: \$${order['total_price']?.toStringAsFixed(2) ?? '0.00'}'),
            const Divider(),
            Text('Customer: ${customer['name'] ?? 'N/A'}'),
            Text('Phone: ${customer['phone'] ?? 'N/A'}'),
            Text('Address: ${customer['address'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _updateStatus(context, 'preparing'),
                  child: const Text('Mark as Preparing'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateStatus(context, 'completed'),
                  child: const Text('Complete Order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'preparing':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
