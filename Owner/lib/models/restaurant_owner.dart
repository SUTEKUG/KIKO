class RestaurantOwner {
  final String id;
  final String userId;
  final String restaurantId;
  final String username;
  final DateTime createdAt;

  RestaurantOwner({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.username,
    required this.createdAt,
  });

  factory RestaurantOwner.fromJson(Map<String, dynamic> json) {
    return RestaurantOwner(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
