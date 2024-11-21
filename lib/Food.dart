class Food {
  int? id; // Nullable for new objects that are not yet in the database
  String foodName;
  double foodCost;

  Food({
    this.id,
    required this.foodName,
    required this.foodCost,
  });

  // Convert a Food object into a Map (to insert/update in SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_name': foodName,
      'food_cost': foodCost,
    };
  }

  // Create a Food object from a Map (retrieved from SQLite)
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      foodName: map['food_name'],
      foodCost: map['food_cost'],
    );
  }
}
