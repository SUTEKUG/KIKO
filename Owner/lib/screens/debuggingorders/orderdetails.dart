import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_service.dart';
import 'dart:developer' as developer;

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? customerDetails;
  Map<String, dynamic>? menuItemDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final userId = widget.order['user_id'];
      final itemId = widget.order['item_id'];

      developer
          .log('Loading details for user_id: $userId and item_id: $itemId');

      if (userId != null) {
        customerDetails = await _orderService.getCustomerDetails(userId);
        developer.log('Loaded customer details: $customerDetails');
      }
      if (itemId != null) {
        menuItemDetails = await _orderService.getMenuItemDetails(itemId);
        developer.log('Loaded menu item details: $menuItemDetails');
      }
    } catch (e) {
      developer.log('Error loading details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      await _orderService.updateOrderStatus(widget.order['id'], newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update order status: ${e.toString()}')),
      );
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order['status'] as String;
    final createdAt = DateTime.parse(widget.order['created_at'] as String);
    final formattedDate = DateFormat('MMM d, y h:mm a').format(createdAt);

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${(widget.order['id'] as String).substring(0, 8)}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Order Status Section
                  _buildSection(
                    'Order Status',
                    [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Ordered on: $formattedDate'),
                    ],
                  ),

                  // Customer Information Section
                  if (customerDetails != null)
                    _buildSection(
                      'Customer Details',
                      [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(customerDetails!['name'] ?? 'N/A'),
                          subtitle: const Text('Name'),
                        ),
                        if (customerDetails!['phone'] != null)
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text(customerDetails!['phone']),
                            subtitle: const Text('Phone'),
                            onTap: () {
                              // Add phone call functionality here if needed
                            },
                          ),
                        if (customerDetails!['address'] != null)
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(customerDetails!['address']),
                            subtitle: const Text('Address'),
                          ),
                      ],
                    )
                  else
                    _buildSection(
                      'Customer Details',
                      [
                        const ListTile(
                          leading: Icon(Icons.error_outline),
                          title: Text('Customer details not available'),
                        ),
                      ],
                    ),

                  // Order Details Section
                  _buildSection(
                    'Order Details',
                    [
                      if (menuItemDetails != null) ...[
                        ListTile(
                          leading: const Icon(Icons.restaurant_menu),
                          title: Text(menuItemDetails!['name']),
                          subtitle: const Text('Item'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: Text('UGX ${menuItemDetails!['price']}'),
                          subtitle: const Text('Price per item'),
                        ),
                      ],
                      ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(widget.order['quantity'].toString()),
                        subtitle: const Text('Quantity'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text('UGX ${widget.order['total_price']}'),
                        //Text('Total: UGX ${order['total_price']}'),

                        subtitle: const Text('Total Amount'),
                      ),
                    ],
                  ),

                  // Action Buttons
                  if (status != 'completed' && status != 'cancelled')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (status == 'pending')
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus('processing'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Start Processing'),
                            ),
                          if (status == 'processing')
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus('completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Mark as Completed'),
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _updateOrderStatus('cancelled'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel Order'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
