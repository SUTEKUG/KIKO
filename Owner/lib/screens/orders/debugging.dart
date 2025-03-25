import 'package:flutter/material.dart';
import 'package:owner/services/owner_services.dart';
import 'dart:developer' as developer;

class TOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const TOrderDetailsScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  _TOrderDetailsScreenState createState() => _TOrderDetailsScreenState();
}

class _TOrderDetailsScreenState extends State<TOrderDetailsScreen> {
  final _ownerService = OwnerService();
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _customer;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await _ownerService.getOrderItem(widget.orderId);
      if (order != null) {
        final customer = await _ownerService.getCurrentCustomerById(order);
        final items = await _ownerService.getOrderItems(order);

        setState(() {
          _order = order;
          _customer = customer;
          _items = items;
        });
      } else {
        setState(() {
          _error = 'Order not found.';
        });
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching order details',
          error: e, stackTrace: stackTrace);
      setState(() {
        _error = 'Failed to load order details.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
      _error = null;
    });

    try {
      await _ownerService.updateOrderStatus(
        orderId: widget.orderId,
        status: newStatus,
        statusMessage: '',
      );
      developer.log('Order status updated to $newStatus');

      setState(() {
        _order?['status'] = newStatus;
      });
    } catch (e, stackTrace) {
      developer.log('Error updating order status',
          error: e, stackTrace: stackTrace);
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchOrderDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order?['id']}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${_order?['id']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${_order?['status']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Name: ${_customer?['name'] ?? 'N/A'}'),
              Text('Email: ${_customer?['email'] ?? 'N/A'}'),
              Text('Phone: ${_customer?['phone'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_items.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text(item['name'] ?? 'Unknown Item'),
                      subtitle: Text('Quantity: ${item['quantity']}'),
                      trailing: Text('Price: UGX ${item['price']}'),
                    );
                  },
                )
              else
                const Text('No items found for this order.'),
              const SizedBox(height: 16),
              if (_isUpdating) const CircularProgressIndicator(),
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
