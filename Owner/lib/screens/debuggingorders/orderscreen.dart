import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owner/screens/debuggingorders/fooddetailsadded.dart';
import 'dart:developer' as developer;

import 'order_service.dart';
import 'orderdetails.dart';

class OrdersScreenT extends StatefulWidget {
  const OrdersScreenT({Key? key}) : super(key: key);

  @override
  _OrdersScreenTState createState() => _OrdersScreenTState();
}

class _OrdersScreenTState extends State<OrdersScreenT> {
  final _orderService = OrderService();
  String? _restaurantId;
  String? _error;
  Stream<List<Map<String, dynamic>>>? _ordersStream;

  @override
  void initState() {
    super.initState();
    _loadRestaurantId();
  }

  Future<void> _loadRestaurantId() async {
    try {
      final restaurant = await _orderService.getCurrentRestaurant();
      developer.log('Restaurant data: $restaurant', name: 'OrdersScreen');

      if (mounted && restaurant != null) {
        setState(() {
          _restaurantId = restaurant['id'];
          _error = null;
          _ordersStream = _orderService.subscribeToOrders(_restaurantId!);
        });
        developer.log('Restaurant ID loaded: $_restaurantId',
            name: 'OrdersScreen');
      } else {
        setState(() {
          _error = 'Could not load restaurant data';
        });
      }
    } catch (e, stackTrace) {
      developer.log('Error loading restaurant ID',
          error: e, stackTrace: stackTrace, name: 'OrdersScreen');
      if (mounted) {
        setState(() {
          _error = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _navigateToOrderDetails(Map<String, dynamic> order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => POrderDetailsScreen(order: order),
      ),
    );

    // If the order was updated, refresh the orders list
    if (result == true) {
      setState(() {});
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final createdAt = DateTime.parse(order['created_at'] as String);
    final formattedDate = DateFormat('MMM d, y h:mm a').format(createdAt);
    final menuItem = order['menu_items'] as Map<String, dynamic>?;
    final customer = order['new_profiles'] as Map<String, dynamic>?;

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${(order['id'] as String).substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                ],
              ),
              const SizedBox(height: 8),
              if (customer != null) ...[
                Text(
                  'Customer: ${customer['name'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
              ],
              if (menuItem != null) Text('Item: ${menuItem['name']}'),
              Text('Total: UGX ${order['total_price']}'),
              Text('Ordered: $formattedDate'),
              const SizedBox(height: 8),
              const Text(
                'Tap to view details',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRestaurantId,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_restaurantId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading orders: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'New orders will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            ),
          );
        },
      ),
    );
  }
}
