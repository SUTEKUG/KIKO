import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class OwnerService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

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

      if (restaurantResponse != null) {
        // Create restaurant owner
        await supabase.from('restaurant_owners').insert({
          'user_id': authResponse.user!.id,
          'restaurant_id': restaurantResponse['id'],
          'username': username,
        });
      } else {
        developer.log('Error: Unable to create restaurant.');
      }
    }

    return authResponse;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required String statusMessage,
  }) async {
    await supabase.from('orders').update({
      'status': status,
      'status_message': statusMessage,
    }).eq('id', orderId);
  }

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

      // Fetch orders
      final orders = await supabase.from('orders').select('''
            * ,
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

  Future<String?> getSelectedItemName(String orderId) async {
    try {
      final orderData = await Supabase.instance.client
          .from('orders')
          .select('selected_foods')
          .eq('id', orderId)
          .maybeSingle();

      return orderData?['selected_foods']; // This returns the food items string
    } catch (e, stackTrace) {
      developer.log(
        'Error getting selected foods',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentRestaurant() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('No current user found');
        return null;
      }

      final ownerData = await supabase
          .from('restaurant_owners')
          .select('restaurant_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (ownerData == null) {
        developer.log('No restaurant owner data found for user: $userId');
        return null;
      }

      final restaurantData = await supabase
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

  Future<void> removeMenuItem(String itemId) async {
    await supabase.from('menu_items').delete().eq('id', itemId);
  }

  Future<List<Map<String, dynamic>>> getRestaurantMenuItems(
      String restaurantId) async {
    final response = await supabase
        .from('menu_items')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
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
        'Error getting order item',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRestaurantFoodItems(
      String restaurantId) async {
    final response = await supabase
        .from('food_items')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('food_name');

    return List<Map<String, dynamic>>.from(response);
  }

// Add a food item
  Future<void> addFoodItem(String restaurantId, String foodName) async {
    await supabase.from('food_items').insert({
      'restaurant_id': restaurantId,
      'food_name': foodName,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

// Remove a food item
  Future<void> removeFoodItem(String foodItemId) async {
    await supabase.from('food_items').delete().eq('id', foodItemId);
  }

  getCurrentCustomerById(order) {}

  getOrderItems(order) {}

  //addAvailableFood(String itemId, String trim) {}
}

// Outside the `OwnerService` class
Future<Map<String, dynamic>?> getCurrentCustomer() async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      developer.log('No current user found');
      return null;
    }

    final profileData = await Supabase.instance.client
        .from('profiles')
        .select('name, email, phone')
        .eq('user_id', userId)
        .maybeSingle();

    return profileData;
  } catch (e, stackTrace) {
    developer.log(
      'Error getting current customer',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

Future<String?> getSelectedItemName(String orderId) async {
  try {
    final orderData = await Supabase.instance.client
        .from('orders')
        .select('item_id')
        .eq('id', orderId)
        .maybeSingle();

    final itemId = orderData?['item_id'];
    if (itemId == null) return null;

    final itemData = await Supabase.instance.client
        .from('menu_items')
        .select('name')
        .eq('id', itemId)
        .maybeSingle();

    return itemData?['name'];
  } catch (e, stackTrace) {
    developer.log(
      'Error getting selected item name',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
