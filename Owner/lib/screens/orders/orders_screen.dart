import 'package:flutter/material.dart';
import 'package:owner/screens/orders/order_card.dart';
import 'dart:developer' as developer;
import 'package:owner/services/owner_services.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _ownerService = OwnerService();
  String? _restaurantId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurantId();
  }

  Future<void> _loadRestaurantId() async {
    try {
      final restaurant = await _ownerService.getCurrentRestaurant();
      developer.log('Restaurant data: $restaurant', name: 'OrdersScreen');

      if (mounted && restaurant != null) {
        setState(() {
          _restaurantId = restaurant['id'];
          _error = null;
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

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    if (_restaurantId == null) {
      throw Exception('Restaurant ID is not loaded');
    }
    try {
      final orders = await _ownerService.getRestaurantOrders(_restaurantId!);
      developer.log('Orders fetched: ${orders.length}', name: 'OrdersScreen');
      return orders;
    } catch (e, stackTrace) {
      developer.log('Error fetching orders',
          error: e, stackTrace: stackTrace, name: 'OrdersScreen');
      rethrow;
    }
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

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log('Error in orders builder',
                error: snapshot.error, name: 'OrdersScreen');
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
          developer.log('Building orders list with ${orders.length} orders',
              name: 'OrdersScreen');

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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}
