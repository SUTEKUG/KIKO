import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final response = await supabase.from('restaurants').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String restaurantId) async {
    final response = await supabase
        .from('menu_items')
        .select()
        .eq('restaurant_id', restaurantId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('new_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> createOrUpdateProfile({
    required String username,
    required String name,
    required int age,
    required String phone,
    required String address,
    String? hostel,
    String? roomNumber,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final existingProfile = await getCurrentProfile();

    if (existingProfile == null) {
      // Create new profile
      await supabase.from('new_profiles').insert({
        'user_id': userId,
        'username': username,
        'name': name,
        'age': age,
        'phone': phone,
        'address': address,
        'hostel': hostel,
        'room_number': roomNumber,
      });
    } else {
      // Update existing profile
      await supabase.from('new_profiles').update({
        'username': username,
        'name': name,
        'age': age,
        'phone': phone,
        'address': address,
        'hostel': hostel,
        'room_number': roomNumber,
      }).eq('id', existingProfile['id']);
    }
  }

  Future<void> createOrder({
    required String restaurantId,
    required String itemId,
    required int quantity,
    required double totalPrice,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    // First, ensure the user has a profile
    final profile = await supabase
        .from('new_profiles')
        .select()
        .eq('user_id', userId)
        .single();

    // Create the order using the profile's id
    await supabase.from('orders').insert({
      'user_id': profile['id'],
      'restaurant_id': restaurantId,
      'item_id': itemId,
      'quantity': quantity,
      'total_price': totalPrice,
    });
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
}
