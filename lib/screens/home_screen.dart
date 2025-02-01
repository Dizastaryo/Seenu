import 'package:flutter/material.dart';
import 'scan_screen.dart'; // Экран "О компании"
import 'profile_screen.dart'; // Экран профиля
import 'hearts_screen.dart'; // Экран "Мои аренды"

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentPage = 0;

  final List<Widget> _pages = [
    ScanScreen(),
    HeartsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              width: 40, // Указываем размеры круга
              height: 40,
              child: ClipOval(
                child: Image.asset(
                  'assets/amanzat_logo.png',
                  fit: BoxFit.cover, // Логотип заполняет весь круг
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Seenu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.search, color: Colors.black), // Иконка поиска
            onPressed: () {
              Navigator.pushNamed(
                  context, '/search_user'); // Используем именованный маршрут
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentPage],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined), // Современная иконка
            activeIcon: Icon(Icons.dashboard), // Активная версия
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined), // Современная иконка
            activeIcon: Icon(Icons.assignment), // Активная версия
            label: 'Мои признания',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined), // Современная иконка
            activeIcon: Icon(Icons.account_circle), // Активная версия
            label: 'Профиль',
          ),
        ],
        currentIndex: _currentPage,
        selectedItemColor:
            const Color.fromARGB(255, 34, 146, 34), // Цвет активной иконки
        unselectedItemColor:
            const Color.fromARGB(255, 65, 65, 65), // Цвет неактивных иконок
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }
}
