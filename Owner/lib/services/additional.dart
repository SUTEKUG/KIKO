import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class OwnerService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRestaurantOrders(
      String restaurantId) async {
    try {
      developer.log('Fetching orders for restaurant: $restaurantId');

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('No current user logged in.');
        return [];
      }

      // Check owner's permissions
      final ownerData = await supabase
          .from('restaurant_owners')
          .select()
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (ownerData == null) {
        developer.log('No permission for user: $userId');
        return [];
      }

      // Fetch orders with customer and item details
      final orders = await supabase.from('orders').select('''
            *,
            menu_items ( name, price ),
            new_profiles ( name, phone, address )
          ''').eq('restaurant_id', restaurantId);

      return List<Map<String, dynamic>>.from(orders);
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching orders',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOrderCustomer(String orderId) async {
    try {
      final orderData = await supabase
          .from('orders')
          .select('user_id')
          .eq('id', orderId)
          .maybeSingle();

      final userId = orderData?['user_id'];
      if (userId == null) return null;

      final customerData = await supabase
          .from('new_profiles')
          .select('name, phone, address')
          .eq('user_id', userId)
          .maybeSingle();

      return customerData;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching order customer',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOrderItem(String orderId) async {
    try {
      final orderData = await supabase
          .from('orders')
          .select('item_id')
          .eq('id', orderId)
          .maybeSingle();

      final itemId = orderData?['item_id'];
      if (itemId == null) return null;

      final itemData = await supabase
          .from('menu_items')
          .select('name, price')
          .eq('id', itemId)
          .maybeSingle();

      return itemData;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching order item',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
