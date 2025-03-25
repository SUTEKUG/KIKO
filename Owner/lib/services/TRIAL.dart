import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class OwnerService {
  final supabase = Supabase.instance.client;

  // Sign in method
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up method
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String restaurantName,
    required String location,
    required String category,
  }) async {
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      try {
        // Create restaurant
        final restaurantResponse = await supabase
            .from('restaurants')
            .insert({
              'name': restaurantName,
              'location': location,
              'category': category,
            })
            .select('id')
            .single();

        // Create restaurant owner
        await supabase.from('restaurant_owners').insert({
          'user_id': authResponse.user!.id,
          'restaurant_id': restaurantResponse['id'],
          'username': username,
        });
      } catch (e) {
        developer.log('Error: Unable to complete sign-up - $e');
        rethrow;
      }
    }

    return authResponse;
  }

  // Add a menu item
  Future<void> addMenuItem({
    required String restaurantId,
    required String name,
    required double price,
  }) async {
    await supabase.from('menu_items').insert({
      'restaurant_id': restaurantId,
      'name': name,
      'price': price,
    });
  }

  // Remove a menu item
  Future<void> removeMenuItem(String itemId) async {
    await supabase.from('menu_items').delete().eq('id', itemId);
  }

  // Fetch orders
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final response = await supabase
        .from('orders')
        .select('id, created_at')
        .order('created_at', ascending: false);

    if (response.error != null) {
      throw Exception('Error fetching orders: ${response.error!.message}');
    }

    return List<Map<String, dynamic>>.from(response.data);
  }

  // Fetch order details
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    try {
      final orderResponse = await supabase
          .from('orders')
          .select('user_id, item_id, total_price, quantity')
          .eq('id', orderId)
          .single();

      if (orderResponse.error != null) {
        throw Exception(
            'Error fetching order: ${orderResponse.error!.message}');
      }

      final orderData = orderResponse.data;

      // Fetch customer details
      final customerResponse = await supabase
          .from('new_profiles')
          .select('name, email, address')
          .eq('user_id', orderData['user_id'])
          .single();

      // Fetch item details
      final itemResponse = await supabase
          .from('menu_items')
          .select('name')
          .eq('id', orderData['item_id'])
          .single();

      if (customerResponse.error != null || itemResponse.error != null) {
        throw Exception('Error fetching customer or item details');
      }

      return {
        'order_id': orderId,
        'customer_name': customerResponse.data['name'],
        'customer_email': customerResponse.data['email'],
        'customer_address': customerResponse.data['address'],
        'item_name': itemResponse.data['name'],
        'total_price': orderData['total_price'],
        'quantity': orderData['quantity'],
      };
    } catch (e) {
      developer.log('Error fetching order details: $e');
      rethrow;
    }
  }
}
