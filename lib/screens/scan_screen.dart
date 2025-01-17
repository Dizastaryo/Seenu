import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final List<ScanResult> _foundDevices = []; // Храним объекты ScanResult
  bool _isScanning = false;

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // Проверка разрешений и состояния Bluetooth
  Future<bool> _checkPermissionsAndBluetooth() async {
    String errorMessage = '';

    // Запрашиваем разрешения на Bluetooth и геолокацию
    PermissionStatus bluetoothStatus = await Permission.bluetoothScan.request();
    PermissionStatus locationStatus = await Permission.location.request();

    // Если Bluetooth или геолокация не разрешены, показываем сообщение об ошибке
    if (bluetoothStatus.isDenied || locationStatus.isDenied) {
      errorMessage = 'Bluetooth and Location permissions are required.';
    }

    // Проверяем, включён ли Bluetooth
    if (!(await FlutterBluePlus.isOn)) {
      errorMessage = 'Bluetooth is turned off. Please enable it.';
    }

    // Если есть ошибки, показать их пользователю
    if (errorMessage.isNotEmpty) {
      _showErrorDialog(errorMessage);
      return false; // Остановить процесс, если есть ошибки
    }

    return true;
  }

  // Показывает диалоговое окно с сообщением об ошибке
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Запуск сканирования
  Future<void> _startScan() async {
    if (!await _checkPermissionsAndBluetooth())
      return; // Проверка перед сканированием

    setState(() {
      _isScanning = true;
      _foundDevices.clear(); // Очищаем список перед новым сканированием
    });

    try {
      await FlutterBluePlus.startScan();
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          // Добавляем все устройства, не проверяя имя
          _foundDevices.addAll(results);
        });
      });
    } catch (error) {
      debugPrint('Scan error: $error');
    }
  }

  // Остановка сканирования
  void _stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          if (_isScanning)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: Lottie.asset(
                      'assets/animations/pixelated-heart.json', // Анимация во время поиска
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Scanning...', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _foundDevices.length,
              itemBuilder: (context, index) {
                var device = _foundDevices[index].device;
                return ListTile(
                  leading: Icon(Icons.person), // Иконка человека
                  title: Text(
                      device.name.isNotEmpty ? device.name : 'Unknown Device'),
                  subtitle: Text(
                      device.id.toString()), // Выводим уникальный ID устройства
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
                backgroundColor: _isScanning ? Colors.red : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                _isScanning ? Icons.stop : Icons.search,
                color: Colors.white,
              ),
              label: Text(
                _isScanning ? 'Stop Scanning' : 'Start Scanning',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: _isScanning ? _stopScan : _startScan,
            ),
          ),
        ],
      ),
    );
  }
}
