import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_service.dart';
import 'dart:developer' as developer;

class POrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const POrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _POrderDetailsScreenState createState() => _POrderDetailsScreenState();
}

class _POrderDetailsScreenState extends State<POrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? customerDetails;
  String? selectedFoods; // Changed from List to String
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final userId = widget.order['user_id'];
      final selectedFoodsData = widget
          .order['selected_foods']; // Assuming this is a comma-separated string
      developer.log('Loading details for user_id: $userId');

      if (userId != null) {
        customerDetails = await _orderService.getCustomerDetails(userId);
        developer.log('Loaded customer details: $customerDetails');
      }

      if (selectedFoodsData != null) {
        selectedFoods = selectedFoodsData; // Directly assigning the string
        developer.log('Loaded selected foods: $selectedFoods');
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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
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
                color: Colors.blueGrey,
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
    final totalPrice = widget.order['total_price'] as double;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order['id']}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Order Status',
                      [
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Ordered on: $formattedDate',
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                    if (customerDetails != null)
                      _buildSection(
                        'Customer Details',
                        [
                          ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.blueGrey),
                            title: Text(customerDetails!['name'] ?? 'N/A'),
                            subtitle: const Text('Name'),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.phone, color: Colors.blueGrey),
                            title: Text(customerDetails!['phone'] ?? 'N/A'),
                            subtitle: const Text('Phone'),
                          ),
                        ],
                      ),
                    _buildSection(
                      'Ordered Items',
                      selectedFoods != null && selectedFoods!.isNotEmpty
                          ? [
                              ListTile(
                                leading: const Icon(Icons.fastfood,
                                    color: Colors.orange),
                                title: Text(
                                    selectedFoods!), // Displaying the entire string
                              ),
                            ]
                          : [
                              const ListTile(
                                leading: Icon(Icons.warning, color: Colors.red),
                                title: Text('No food items found'),
                              ),
                            ],
                    ),
                    _buildSection(
                      'Total Price',
                      [
                        Text(
                          'UGX ${NumberFormat('#,###').format(totalPrice)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
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
