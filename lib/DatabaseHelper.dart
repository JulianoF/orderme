import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'Food.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('order_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE foods (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      food_name TEXT NOT NULL,
      food_cost REAL NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_date TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER NOT NULL,
      food_id INTEGER NOT NULL,
      FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
      FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE
    )
  ''');
  }

  Future<int> addFood(Food food) async {
    final db = await instance.database;
    return await db.insert('foods', food.toMap());
  }

  Future<List<Food>> getAllFoods() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return List.generate(maps.length, (i) {
      return Food.fromMap(maps[i]);
    });
  }

  Future<List<Food>> searchFoodlessThanPrice(double price) async {
    final db = await instance.database;
    final result = await db.query(
      'foods',
      where: 'food_cost <= ?',
      whereArgs: [price],
    );
    return result.map((json) => Food.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await instance.database;
    final orders = await db.query('orders');
    final List<Map<String, dynamic>> result = [];

    for (var order in orders) {
      final orderId = order['id'];
      final orderDate = order['order_date'];

      final foodItems = await db.rawQuery('''
      SELECT f.food_name, f.food_cost
      FROM order_items oi
      INNER JOIN foods f ON oi.food_id = f.id
      WHERE oi.order_id = ?
    ''', [orderId]);

      result.add({
        'id': orderId,
        'order_date': orderDate,
        'foodList': foodItems.map((food) => Food.fromMap(food)).toList(),
      });
    }

    return result;
  }

  Future<void> insertOrder(List<int> foodIds, String orderDate) async {

    final db = await instance.database;

    int orderId = await db.insert('orders', {'order_date': orderDate});

    for (int foodId in foodIds) {
      await db.insert('order_items', {
        'order_id': orderId,
        'food_id': foodId,
      });
    }
  }

  Future<void> deleteOrder(int orderId) async {
    final db = await instance.database;
    await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}