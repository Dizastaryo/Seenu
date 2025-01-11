import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final List<String> _foundDevices = []; // Список только имен устройств
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  // Запуск сканирования
  void _startScan() async {
    setState(() {
      _isScanning = true;
      _foundDevices.clear(); // Очищаем список перед новым сканированием
    });

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          // Добавляем только имена устройств
          for (var result in results) {
            if (result.device.name.isNotEmpty &&
                !_foundDevices.contains(result.device.name)) {
              _foundDevices.add(result.device.name);
            }
          }
        });
      });
    } catch (error) {
      debugPrint('Scan error: $error');
    } finally {
      setState(() {
        _isScanning = false;
      });
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
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.search),
            onPressed: _isScanning ? _stopScan : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScanning)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Scanning...'),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: _foundDevices.map((deviceName) {
                return ListTile(
                  title: Text(
                      deviceName.isNotEmpty ? deviceName : 'Unknown Device'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
