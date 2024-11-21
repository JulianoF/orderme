import 'package:flutter/material.dart';
import 'Food.dart';

class OrderCard extends StatelessWidget {
  final String date;
  final double totalCost;
  final List<Food> foodList;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.date,
    required this.totalCost,
    required this.foodList,
    required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: Colors.blueGrey[100],
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "\$${totalCost.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 25.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER ITEMS',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    ...foodList.map((food) {
                      return Text(
                        food.foodName,
                        style: const TextStyle(fontSize: 14.0),
                      );
                    }),
                  ],
                ),
              ),
              TextButton(
                onPressed: onDelete,
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
