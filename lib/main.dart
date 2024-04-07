import 'package:flutter/material.dart';
import 'package:flutter_video/app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize Hive before runApp
  await Hive.initFlutter();
  await Hive.openBox('grocery_list'); //this is to open a box in Hive
  //can be any name you like
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

//Flutter API Calling & Local Database (EP10)
//Local Database - NoSQL Database, Hive (part 1)

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //create a new class for this
      home: Demo(),
    );
  }
}
