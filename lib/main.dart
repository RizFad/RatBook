import 'package:flutter/material.dart';
import 'package:rat_book/pages/main_page.dart';
import 'package:rat_book/pages/login_page.dart';

void main(){  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key ? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/main': (context) => MainPage(),
      },
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}