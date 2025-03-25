import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class OwnService {
  final supabase = Supabase.instance.client;

  // Fetch basic order details from the orders table
  Future<List<Map<String, dynamic>>> getOrderDetails(
      String restaurantId) async {
    try {
      developer.log('Fetching order details for restaurant: $restaurantId');

      final orders = await supabase
          .from('orders')
          .select('user_id, item_id, quantity')
          .eq('restaurant_id', restaurantId);

      return List<Map<String, dynamic>>.from(orders);
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching order details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Fetch user profile details using user_id from the new_profiles table
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      developer.log('Fetching user profile for user_id: $userId');

      final profileData = await supabase
          .from('new_profiles')
          .select('name, phone, address')
          .eq('id', userId)
          .maybeSingle();

      return profileData;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching user profile',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Fetch item details using item_id from the menu_items table
  Future<Map<String, dynamic>?> getItemDetails(String itemId) async {
    try {
      developer.log('Fetching item details for item_id: $itemId');

      final itemData = await supabase
          .from('menu_items')
          .select('name, price')
          .eq('id', itemId)
          .maybeSingle();

      return itemData;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching item details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  getOrderById(String orderId) {}
}

// Example usage
void exampleUsage() async {
  final ownService = OwnService();

  // Step 1: Get basic order details
  final restaurantId = 'example_restaurant_id';
  final orders = await ownService.getOrderDetails(restaurantId);
  developer.log('Orders: $orders');

  // Step 2: Get additional details for each order
  for (final order in orders) {
    final userId = order['user_id'];
    final itemId = order['item_id'];

    // Fetch user profile
    final userProfile = await ownService.getUserProfile(userId);
    developer.log('User Profile: $userProfile');

    // Fetch item details
    final itemDetails = await ownService.getItemDetails(itemId);
    developer.log('Item Details: $itemDetails');
  }
}
