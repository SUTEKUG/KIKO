import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class OrderService {
  final _supabase = Supabase.instance.client;

  // Get current restaurant details for the logged-in owner
  Future<Map<String, dynamic>?> getCurrentRestaurant() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('No current user found');
        return null;
      }

      final ownerData = await _supabase
          .from('restaurant_owners')
          .select('restaurant_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (ownerData == null) {
        developer.log('No restaurant owner data found for user: $userId');
        return null;
      }

      final restaurantData = await _supabase
          .from('restaurants')
          .select()
          .eq('id', ownerData['restaurant_id'])
          .maybeSingle();

      return restaurantData;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting current restaurant',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Fetch orders for a specific restaurant with related data
  Future<List<Map<String, dynamic>>> getRestaurantOrders(
      String restaurantId) async {
    try {
      developer.log('Fetching orders for restaurant: $restaurantId');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('No current user logged in.');
        return [];
      }

      // Verify owner's permissions
      final ownerData = await _supabase
          .from('restaurant_owners')
          .select()
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (ownerData == null) {
        developer.log('No permission for user: $userId');
        return [];
      }

      // Fetch orders with related data using proper join syntax
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            menu_items (
              name,
              price
            ),
            new_profiles!user_id (
              name,
              phone,
              address
            )
          ''')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      developer.log('Orders response: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching orders',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('orders').update({
        'status': newStatus,
        'status_message': 'Order $newStatus',
      }).eq('id', orderId);
    } catch (e, stackTrace) {
      developer.log(
        'Error updating order status',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Subscribe to real-time order updates
  Stream<List<Map<String, dynamic>>> subscribeToOrders(String restaurantId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', restaurantId)
        .order('created_at')
        .map((events) => List<Map<String, dynamic>>.from(events));
  }

  // Get customer details by ID
  Future<Map<String, dynamic>?> getCustomerDetails(String userId) async {
    try {
      developer.log('Fetching customer details for user ID: $userId');
      final response = await _supabase
          .from('new_profiles')
          .select('name, phone, address')
          .eq('id', userId)
          .maybeSingle();

      developer.log('Customer details response: $response');
      return response;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching customer details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Get menu item details by ID
  Future<Map<String, dynamic>?> getMenuItemDetails(String itemId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('name, price')
          .eq('id', itemId)
          .maybeSingle();
      return response;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching menu item details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
