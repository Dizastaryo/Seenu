import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<WiFiAccessPoint> _wifiSSIDs = [];
  bool _isScanning = false;
  String _logMessage = "";

  @override
  void initState() {
    super.initState();
  }

  // Функция для обработки сканирования Wi-Fi
  Future<void> _scanWifi() async {
    setState(() {
      _isScanning = true;
      _logMessage = "Запрос разрешений на местоположение...";
    });
    _showLogMessage(_logMessage);

    // Проверка разрешений на местоположение
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          _isScanning = false;
          _logMessage = "Разрешение на местоположение отклонено.";
        });
        _showLogMessage(_logMessage);
        return;
      }
    }

    setState(() {
      _logMessage = "Разрешение на местоположение получено.";
    });
    _showLogMessage(_logMessage);

    // Начало сканирования
    try {
      final canStart = await WiFiScan.instance.canStartScan();
      if (canStart != CanStartScan.yes) {
        setState(() {
          _logMessage = "Невозможно начать сканирование.";
        });
        _showLogMessage(_logMessage);
        return;
      }

      await WiFiScan.instance.startScan();
      setState(() {
        _logMessage = "Сканирование начато.";
      });
      _showLogMessage(_logMessage);

      // Получение результатов сканирования
      final results = await WiFiScan.instance.getScannedResults();
      setState(() {
        _wifiSSIDs = results;
        _logMessage = "Найдено ${_wifiSSIDs.length} сетей Wi-Fi.";
      });
      _showLogMessage(_logMessage);
    } catch (e) {
      setState(() {
        _logMessage = 'Ошибка при сканировании Wi-Fi: $e';
      });
      _showLogMessage(_logMessage);
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  // Функция для отображения лога
  void _showLogMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Scanner'),
      ),
      body: Center(
        child: _isScanning
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: _wifiSSIDs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_wifiSSIDs[index].ssid),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _scanWifi,
        child: Icon(Icons.search),
      ),
    );
  }
}
