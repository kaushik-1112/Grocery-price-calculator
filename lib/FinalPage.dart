import 'package:flutter/material.dart';

class FinalPage extends StatelessWidget {
  final List<Map<String, dynamic>> groceryList;

  FinalPage({required this.groceryList});

  @override
  Widget build(BuildContext context) {
    // Calculate the total price
    double totalPrice = 0.0;
    for (final item in groceryList) {
      totalPrice += item['quantity'] * item['price'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Final Grocery List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                DataTable(
                  columns: [
                    DataColumn(label: Text('S.No')),
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Total Price')),
                  ],
                  rows: List.generate(
                    groceryList.length,
                    (index) {
                      final item = groceryList[index];
                      final totalItemPrice = item['quantity'] * item['price'];
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(item['item'])),
                        DataCell(Text('Rs.${item['price'].toString()}')),
                        DataCell(Text(item['quantity'].toString())),
                        DataCell(Text(item['date'])),
                        DataCell(Text('Rs.${totalItemPrice.toString()}')),
                      ]);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Final Total Price: Rs.${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
