import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class HiveHelper {
  //get the opened box
  static final _groceryList = Hive.box('grocery_list');

  //read data from Hive in Map<String, dynamic>
  //remember Hive is Key-Value pair storage
  //Hive could have custom object, will be discussed on next video
  static List<Map<String, dynamic>> getGroceries() {
    //this is to get data according to its key
    var groceryList = _groceryList.keys.map((key) {
      var value = _groceryList.get(key); //get key and assign value
      //this return is Map<String, dynamic> type
      //and these variable are used in this tutorial
      return {
        "key": key,
        "item": value['item'],
        "quantity": value['quantity'],
        "price": value["price"],
        "date": value['date'],
      };
    }).toList();

    return groceryList; //return a list of grocery item
  }

  //add grocery item into Hive
  static Future<void> addItem(Map<String, dynamic> newItem) async {
    await _groceryList.add(newItem); //add new item into Hive
  }

  //update grocery list in Hive
  static Future<void> updateItem(
      int itemKey, Map<String, dynamic> oldItem) async {
    //use put() to update
    //update old item according to its key
    await _groceryList.put(itemKey, oldItem);
  }

  //delete grocery item in Hive
  static Future<void> deleteItem(int itemKey) async {
    //delete item according to its key
    await _groceryList.delete(itemKey);
  }
}

//now, lets build ui