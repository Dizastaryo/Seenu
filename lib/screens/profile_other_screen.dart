import 'package:flutter/material.dart';

class ProfileOtherScreen extends StatelessWidget {
  final String name;
  final String photoUrl;
  final int signals;

  ProfileOtherScreen(
      {required this.name, required this.photoUrl, required this.signals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, // Размер изображения
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover, // Масштабирование изображения
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  '$signals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
