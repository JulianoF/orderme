import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'OrderCard.dart';
import 'Food.dart';
import 'AddFood.dart';
import 'AddOrder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'OrderMe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _orders = [];
  String query = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orders = await DatabaseHelper.instance.getAllOrders();
    setState(() {
      _orders = orders;
      isLoading = false;
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    await DatabaseHelper.instance.deleteOrder(orderId);
    setState(() {
      _orders.removeWhere((order) => order['id'] == orderId);
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (text) {
                setState(() {
                  query = text;
                });
              },
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                  ? const Center(child: Text("No Orders Here!!"))
                  : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final date = order['order_date'] ?? 'Unknown Date';
                  final foodList = List<Food>.from(
                    order['foodList'] ?? [],
                  );
                  final totalCost = foodList.fold(
                    0.0,
                        (sum, food) => sum + (food.foodCost ?? 0.0),
                  );
                  return OrderCard(
                    date: date,
                    foodList: foodList,
                    totalCost: totalCost,
                    onDelete: () => _deleteOrder(order['id']),
                  );
                },
              ),
            ),
            const SizedBox(height: 15.0),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddFood()),
                      );
                      if (result == true) {
                        _fetchOrders();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                    child: const Text(
                      "Add Food",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddOrder()),
                      );
                      if (result == true) {
                        _fetchOrders();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                    child: const Text(
                      "New Order",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15.0),
          ],
        ),
      ),
    );
  }
}

