import 'package:flutter/material.dart';
import 'package:rat_book/models/database.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final AppDatabase database = AppDatabase();
  
  
  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final user = await database.findUserByUsername('rizqy');
      if (user == null) {        
        await database.insertUserRepo('rizqy', '123456789');
        print('User rizqy ditambahkan.');
      } else {
        print('User rizqy sudah ada.');
      }
    } catch (e) {
      print('Terjadi kesalahan saat memeriksa/menambahkan data pengguna: $e');
    }
  }

  void _login(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Isi username dan password.'),
      ));
      return;
    }

    final user = await database.findUserByUsername(username);

    if (user != null) {      
      final encryptedPassword = _encryptPassword(password);
      if (user.password == encryptedPassword) {        
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password salah.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pengguna dengan username yang diberikan tidak ditemukan.'),
      ));
    }    
  }

  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[            
            Image.asset(
              'lib/images/image.png',
              width: 100, 
              height: 100,
            ),
            SizedBox(height: 10),
            Text(
              'RAT BOOK',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}