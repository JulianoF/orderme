
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'DatabaseHelper.dart';
import 'Food.dart';

class AddFood extends StatefulWidget{

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _foodCostController = TextEditingController();

  @override
  void dispose() {
    _foodNameController.dispose();
    _foodCostController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveOrUpdateFood() async {
    final foodName = _foodNameController.text.trim();
    final foodCostText = _foodCostController.text.trim();

    // Check if fields are empty or invalid
    if (foodName.isEmpty) {
      Fluttertoast.showToast(
        msg: "Food name cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (foodCostText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Food cost cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final foodCost = double.tryParse(foodCostText);
    if (foodCost == null || foodCost <= 0) {
      Fluttertoast.showToast(
        msg: "Please enter a valid food cost greater than 0",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final newFood = Food(foodName: foodName, foodCost: foodCost);

    await DatabaseHelper.instance.addFood(newFood);

    Fluttertoast.showToast(
      msg: "Food item added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              'Add a New Food Item to the Database!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30.0),
            TextFormField(
              controller: _foodCostController,
              decoration: const InputDecoration(
                labelText: 'Food Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: _saveOrUpdateFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              child: const Text('Add Food',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
