
import 'Food.dart';

class Order {
  int? id; // Nullable for new objects
  String orderDate; // Stored as a String (e.g., ISO 8601 format)
  List<Food> foodItems; // A list of Food objects associated with the order

  Order({
    this.id,
    required this.orderDate,
    required this.foodItems,
  });

  // Convert an Order object into a Map (only order-specific data)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_date': orderDate,
    };
  }

  // Create an Order object from a Map (does not include food items)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderDate: map['order_date'],
      foodItems: [], // Food items must be populated separately
    );
  }

  // Convert the full Order object to a Map with nested food items
  Map<String, dynamic> toDetailedMap() {
    return {
      'id': id,
      'order_date': orderDate,
      'food_items': foodItems.map((food) => food.toMap()).toList(),
    };
  }

  // Populate food items from a list of maps
  void addFoodItemsFromMaps(List<Map<String, dynamic>> foodMaps) {
    foodItems = foodMaps.map((map) => Food.fromMap(map)).toList();
  }
}
