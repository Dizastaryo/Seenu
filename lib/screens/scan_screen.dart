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
  List<String> _logMessages = [];

  @override
  void initState() {
    super.initState();
    _addLogMessage("Приложение запущено.");
  }

  Future<void> _scanWifi() async {
    setState(() {
      _isScanning = true;
      _addLogMessage("Инициализация сканирования...");
    });

    if (await _requestLocationPermission()) {
      _addLogMessage("Разрешение на местоположение подтверждено.");
      await _startWifiScan();
    } else {
      setState(() {
        _isScanning = false;
        _addLogMessage("Разрешение на местоположение отклонено.");
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    _addLogMessage("Статус разрешения на местоположение: $status");

    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.location.request();
      _addLogMessage("Запрос разрешения на местоположение: $status");

      if (status.isDenied || status.isPermanentlyDenied) {
        _addLogMessage(
            "Ошибка: Проверьте настройки Info.plist и убедитесь, что необходимые ключи добавлены.");
      }
    }
    return status.isGranted;
  }

  Future<void> _startWifiScan() async {
    try {
      final canStart = await WiFiScan.instance.canStartScan();
      _addLogMessage("Проверка возможности сканирования: $canStart");

      if (canStart != CanStartScan.yes) {
        setState(() {
          _addLogMessage("Сканирование невозможно. Причина: $canStart");
        });
        return;
      }

      await WiFiScan.instance.startScan();
      _addLogMessage("Сканирование начато.");

      final results = await WiFiScan.instance.getScannedResults();
      _addLogMessage("Получение результатов сканирования...");

      setState(() {
        _wifiSSIDs = results;
        _addLogMessage(
            "Сканирование завершено. Найдено ${_wifiSSIDs.length} сетей.");
      });
    } catch (e) {
      setState(() {
        _addLogMessage('Ошибка при сканировании: $e');
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _addLogMessage(String message) {
    print(message); // Вывод в консоль для отладки
    setState(() {
      _logMessages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _logMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_logMessages[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _scanWifi,
        child: Icon(Icons.search),
      ),
    );
  }
}
