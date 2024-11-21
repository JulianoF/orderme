import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'Food.dart'; // Replace with your actual file

class AddOrder extends StatefulWidget {
  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  TextEditingController targetCostController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String searchDate = '';
  List<Food> allFoods = [];
  List<Food> filteredFoods = [];
  List<Food> addedItems = [];
  double totalCost = 0.0;
  String? selectedItem;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    allFoods = await DatabaseHelper.instance.getAllFoods();
    setState(() {
      filteredFoods = allFoods;
    });
  }

  Future<void> _saveOrUpdateOrder() async {
    if (addedItems.isEmpty || searchDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add items and select a date!')),
      );
      return;
    }

    List<int> foodIds = addedItems
        .map((food) => food.id)
        .whereType<int>()
        .toList();

    try {
      await DatabaseHelper.instance.insertOrder(foodIds, searchDate);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order saved successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save order: $e')),
      );
    }
  }

  void filterItems() {
    double? targetCost = double.tryParse(targetCostController.text);
    if (targetCost != null) {
      double remainingBudget = targetCost - totalCost;

      DatabaseHelper.instance.searchFoodlessThanPrice(remainingBudget).then((foods) {
        setState(() {
          filteredFoods = foods;
        });
      });
    } else {
      setState(() {
        filteredFoods = allFoods;
      });
    }
  }


  void addItem(Food food) {
    if (!addedItems.contains(food)) {
      setState(() {
        addedItems.add(food);
        totalCost += food.foodCost;
      });
    }
    filterItems();
  }

  void removeItem(Food food) {
    setState(() {
      addedItems.remove(food);
      totalCost -= food.foodCost;
    });
    filterItems();
  }

  void pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        searchDate = pickedDate.toLocal().toString().split(' ')[0];
        dateController.text = searchDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: targetCostController,
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Target Cost',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => filterItems(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => pickDate(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = filteredFoods[index];
                  bool isSelected = selectedItem == food.foodName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedItem = isSelected ? null : food.foodName;
                      });
                    },
                    child: Container(
                      color: isSelected ? Colors.blueAccent : Colors.transparent,
                      child: ListTile(
                        title: Text(food.foodName),
                        subtitle: Text(
                            'Price: \$${food.foodCost.toStringAsFixed(2)}'),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: selectedItem == null ? null : () {
                addItem(filteredFoods.firstWhere((food) => food.foodName == selectedItem));
                setState(() {
                  selectedItem = null;
                });
              },
              child: Text('Add'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: addedItems.length,
                itemBuilder: (context, index) {
                  final food = addedItems[index];
                  return ListTile(
                    title: Text(food.foodName),
                    subtitle: Text(
                        'Price: \$${food.foodCost.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () => removeItem(food),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total cost: \$${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: _saveOrUpdateOrder,
                  child: Text('Save Order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

