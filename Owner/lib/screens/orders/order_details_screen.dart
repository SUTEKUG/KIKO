import 'package:flutter/material.dart';
import 'package:owner/services/owner_services.dart';
import 'dart:developer' as developer;

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _ownerService = OwnerService();
  bool _isUpdating = false;
  String? _error;
  late Map<String, dynamic> order;

  @override
  void initState() {
    super.initState();
    order = Map.from(widget.order);
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
      _error = null;
    });

    try {
      await _ownerService.updateOrderStatus(
        orderId: order['id'],
        status: newStatus,
        statusMessage: '',
      );
      developer.log('Order status updated to $newStatus');

      setState(() {
        order['status'] = newStatus;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error updating order status',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _error = 'Failed to update order status. Please try again later.';
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = order['customer'] ?? {};
    final items = order['item'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order['id']}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${order['id']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${order['status']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Name: ${customer['name'] ?? 'N/A'}'),
              Text('Email: ${customer['email'] ?? 'N/A'}'),
              Text('Phone: ${customer['phone'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (items.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text('Quantity: ${item['quantity']}'),
                      trailing: Text('Price: ${item['price']}'),
                    );
                  },
                )
              else
                const Text('No items found for this order.'),
              const SizedBox(height: 16),
              if (_isUpdating) const CircularProgressIndicator(),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: !_isUpdating
                        ? () => _updateOrderStatus('Processing')
                        : null,
                    child: const Text('Mark as Processing'),
                  ),
                  ElevatedButton(
                    onPressed: !_isUpdating
                        ? () => _updateOrderStatus('Completed')
                        : null,
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
