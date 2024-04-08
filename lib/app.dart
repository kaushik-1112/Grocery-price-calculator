import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_video/hivecode.dart';
import 'package:flutter_video/FinalPage.dart';

class Demo extends StatefulWidget {
  Demo({Key? key}) : super(key: key);

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<Map<String, dynamic>> _groceryItem = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  double? budget; // Change to nullable double to handle user input

  @override
  void initState() {
    super.initState();
    _loadGroceryItems();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadGroceryItems() async {
    setState(() {
      _groceryItem = HiveHelper.getGroceries();
    });
  }

  final _budgetController = TextEditingController(); // Controller for budget input field
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grocery Shopping Calculator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
        backgroundColor: Colors.pink,
      ),
      body: _groceryItem.isEmpty
          ? Center(
              child: Text(
                'No Grocery Items added yet!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: _groceryItem.length,
              itemBuilder: (context, index) {
                final _item = _groceryItem[index];
                return Card(
                  elevation: 5,
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_item['item']),
                              Text(
                                'Rs.${_item['price']}',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            HiveHelper.deleteItem(_item['key']);
                            _loadGroceryItems();
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(_item['date']),
                    leading: Text(_item['quantity'].toString()),
                    onTap: () => _groceryModel(context, _item['key']),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                onPressed: () => _groceryModel(context, null),
                icon: Icon(Icons.add),
                label: Text('Add Item'),
                tooltip: 'Add a new grocery item',
                backgroundColor: Colors.green,
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showBudgetDialog(context); // Show budget input dialog
            },
            child: Text('Set Budget'),
            style: ElevatedButton.styleFrom(
              elevation: 4,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveGroceryList,
            child: Text('View Final List'),
            style: ElevatedButton.styleFrom(
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  void _saveGroceryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'groceryList',
      _groceryItem.map((item) => item.toString()).toList(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grocery list saved to Shared Preferences.'),
      ),
    );

    double totalPrice = _groceryItem.fold(0, (total, item) => total + (item['price']*item['quantity']));

    String message = 'Final price is: Rs.$totalPrice';

    _showNotification(message);

    if (budget != null) {
      if (totalPrice > budget!) {
        _showNotification('Your final price exceeds your wallet. No sufficient money.');
      } else {
        double remainingAmount = budget! - totalPrice;
        _showNotification('List created. Here\'s your remaining in wallet: Rs.$remainingAmount');
      }
    } else {
      _showNotification('Budget not set. Please set your budget.');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalPage(groceryList: _groceryItem),
      ),
    );
  }

  void _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description',
            importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Grocery List',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _groceryModel(BuildContext context, int? key) {
    if (key != null) {
      final _currentItem = _groceryItem.firstWhere((item) => item['key'] == key);
      _itemController.text = _currentItem['item'];
      _quantityController.text = _currentItem['quantity'].toString();
      _priceController.text = _currentItem['price'].toStringAsFixed(2);
      _dateController.text = _currentItem['date'];
    } else {
      _itemController.clear();
      _quantityController.clear();
      _priceController.clear();
      _dateController.clear();
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: key == null ? Text('Add Items') : Text('Update Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField(_itemController, 'Item'),
              SizedBox(height: 10),
              _buildQuantityField(_quantityController, 'Quantity'),
              SizedBox(height: 10),
              _buildTextField(_priceController, 'Price'),
              SizedBox(height: 10),
              _buildDateField(_dateController, 'Date'),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                double price = _priceController.text.isNotEmpty ? double.parse(_priceController.text) : 0.0;

                if (key == null) {
                  HiveHelper.addItem({
                    'item': _itemController.text,
                    'quantity': int.parse(_quantityController.text),
                    'price': price,
                    'date': _selectedDate.toString().split(' ')[0],
                  });
                } else {
                  HiveHelper.updateItem(key, {
                    'item': _itemController.text,
                    'quantity': int.parse(_quantityController.text),
                    'price': price,
                    'date': _selectedDate.toString().split(' ')[0],
                  });
                }

                _itemController.clear();
                _quantityController.clear();
                _priceController.clear();
                _dateController.clear();

                _loadGroceryItems();

                Navigator.of(context).pop();
              },
              child: key == null ? Text('Add New') : Text('Update'),
            )
          ],
        );
      },
    );
  }

  TextField _buildTextField(TextEditingController _controller, String hint) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
      ),
    );
  }

  Widget _buildQuantityField(TextEditingController _controller, String hint) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
      ),
    );
  }

  Widget _buildDateField(TextEditingController _controller, String hint) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2015, 8),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null && pickedDate != _selectedDate)
              setState(() {
                _selectedDate = pickedDate;
                _controller.text = _selectedDate.toString().split(' ')[0];
              });
          },
        ),
      ),
      readOnly: true,
    );
  }

  void _showBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Budget'),
          content: TextFormField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your budget',
              labelText: 'Budget',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  budget = double.tryParse(_budgetController.text);
                });
                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }
}
