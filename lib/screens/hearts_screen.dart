import 'package:flutter/material.dart';

class HeartsScreen extends StatefulWidget {
  @override
  _HeartsScreenState createState() => _HeartsScreenState();
}

class _HeartsScreenState extends State<HeartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> anonymousUsers = [
    {
      'name': 'Аноним 1',
      'photo':
          'https://avatars.mds.yandex.net/i?id=e65f5b18123d8615b3e56a85732b957fdd7146beab23b66b-5754670-images-thumbs&n=13'
    },
    {
      'name': 'Аноним 2',
      'photo':
          'https://avatars.mds.yandex.net/i?id=e65f5b18123d8615b3e56a85732b957fdd7146beab23b66b-5754670-images-thumbs&n=13'
    },
  ];

  final List<Map<String, String>> nonAnonymousUsers = [
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black45,
                indicatorColor: Colors.green,
                tabs: [
                  Tab(
                    text: 'Анонимно',
                    icon: Icon(Icons.security_outlined),
                  ),
                  Tab(
                    text: 'Не анонимно',
                    icon: Icon(Icons.person_outline),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(anonymousUsers),
                  _buildUserList(nonAnonymousUsers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, String>> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(users[index]['photo']!),
              backgroundColor: Colors.grey[200],
            ),
            title: Text(
              users[index]['name']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: Icon(
              Icons.favorite,
              color: Colors.redAccent,
            ),
          ),
        );
      },
    );
  }
}
