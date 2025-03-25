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
          .select()
          .single();

      // Create restaurant owner
      await supabase.from('restaurant_owners').insert({
        'user_id': authResponse.user!.id,
        'restaurant_id': restaurantResponse['id'],
        'username': username,
      });
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

      final response = await supabase
          .from('orders')
          .select('''
            id,
            quantity,
            total_price,
            status,
            status_message,
            created_at,
            menu_items!inner (
              id,
              name,
              price
            ),
            new_profiles!inner (
              id,
              name,
              phone,
              address
            )
          ''')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      developer.log('Orders fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      developer.log('Error fetching orders', error: e, stackTrace: stackTrace);
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
          .single();

      if (ownerData == null) {
        developer.log('No restaurant owner data found for user: $userId');
        return null;
      }

      final restaurantData = await supabase
          .from('restaurants')
          .select()
          .eq('id', ownerData['restaurant_id'])
          .single();

      developer.log('Restaurant data fetched: ${restaurantData['id']}');
      return restaurantData;
    } catch (e, stackTrace) {
      developer.log('Error getting current restaurant',
          error: e, stackTrace: stackTrace);
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
}
