import 'package:flutter/material.dart';

class SearchUserScreen extends StatefulWidget {
  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> allUsers = [
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
  List<Map<String, String>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = allUsers; // Изначально показываем всех пользователей
  }

  void _searchUsers() {
    setState(() {
      filteredUsers = allUsers
          .where((user) => user['name']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск пользователей'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Введите имя пользователя',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) => _searchUsers(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage(filteredUsers[index]['photo']!),
                      ),
                      title: Text(
                        filteredUsers[index]['name']!,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        // Здесь можно перейти на экран профиля выбранного пользователя
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
