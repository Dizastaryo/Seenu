import 'package:flutter/material.dart';
import 'profile_other_screen.dart';

class ScanScreen extends StatelessWidget {
  final List<Map<String, String>> users = [
    {
      'name': 'Алексей',
      'photo':
          'https://workspace.ru/upload/main/b10/id0trmk3kzzzvw18e0hdm56eqxad6c0h/shrek.jpg'
    },
    {
      'name': 'Мария',
      'photo':
          'https://workspace.ru/upload/main/b10/id0trmk3kzzzvw18e0hdm56eqxad6c0h/shrek.jpg'
    },
    {
      'name': 'Дмитрий',
      'photo':
          'https://workspace.ru/upload/main/b10/id0trmk3kzzzvw18e0hdm56eqxad6c0h/shrek.jpg'
    },
    {
      'name': 'Екатерина',
      'photo':
          'https://workspace.ru/upload/main/b10/id0trmk3kzzzvw18e0hdm56eqxad6c0h/shrek.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Убираем AppBar
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                leading: Container(
                  width: 60, // Размер изображения
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(users[index]['photo']!),
                      fit: BoxFit.cover, // Масштабирование изображения
                    ),
                  ),
                ),
                title: Text(
                  users[index]['name']!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileOtherScreen(
                        name: users[index]['name']!,
                        photoUrl: users[index]['photo']!,
                        signals: 23,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
