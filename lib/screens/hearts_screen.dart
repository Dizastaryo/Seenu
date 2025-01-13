import 'package:flutter/material.dart';
import 'package:location/location.dart';

class HeartsScreen extends StatefulWidget {
  @override
  _HeartsScreenState createState() => _HeartsScreenState();
}

class _HeartsScreenState extends State<HeartsScreen> {
  final Location location = Location();
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Проверяем, включены ли службы геолокации
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Если службы не включены, уведомляем пользователя
        _showErrorDialog('Службы геолокации отключены.');
        return;
      }
    }

    // Проверяем разрешение на доступ
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Если разрешение не предоставлено, уведомляем пользователя
        _showErrorDialog('Разрешение на доступ к местоположению отклонено.');
        return;
      }
    }

    // Разрешение предоставлено
    setState(() {
      _locationGranted = true;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('ОК'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hearts Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: _locationGranted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 100.0,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to the Hearts Screen!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                'Ожидание разрешения на доступ к местоположению...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
