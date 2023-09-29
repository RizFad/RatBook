import 'package:flutter/material.dart';
import 'package:rat_book/models/database.dart'; 

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  final AppDatabase database = AppDatabase();

  void _savePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    
    final currentUser = await database.findUserByUsername('rizqy'); 
    if (currentUser != null && currentUser.password == oldPassword) {      
      await database.updateUserPassword(currentUser.id, newPassword);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sukses'),
            content: Text('Kata sandi berhasil diubah.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Jika kata sandi lama tidak cocok, tampilkan pesan kesalahan
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Kata sandi lama tidak cocok.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ganti Kata Sandi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              obscureText: true, 
              decoration: InputDecoration(
                labelText: 'Kata Sandi Lama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Baru',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePassword,
              child: Text('Save'),
            ),
            SizedBox(height: 30),
            Divider(), 
            SizedBox(height: 20),
            Row(
              children: [
                Image.asset(
                  'lib/images/image.png',
                  width: 80, 
                  height: 80,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama: Rizqy Ghaniyyu F.',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'NIM: 1941720112',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Created: 2023',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Aplikasi: RAT BOOK',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
