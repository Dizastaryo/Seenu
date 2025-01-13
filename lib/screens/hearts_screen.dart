import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wifi_scan/wifi_scan.dart';

class HeartsScreen extends StatefulWidget {
  @override
  _HeartsScreenState createState() => _HeartsScreenState();
}

class _HeartsScreenState extends State<HeartsScreen> {
  final Location location = Location();
  bool _locationGranted = false;
  List<WiFiAccessPoint> _wifiList = [];
  bool _isScanning = false;
  String _logs = ''; // Переменная для хранения логов

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkAndRequestLocationPermission();
    if (_locationGranted) {
      await _scanWiFiNetworks();
    }
  }

  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showErrorDialog('Службы геолокации отключены.');
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showErrorDialog('Разрешение на доступ к местоположению отклонено.');
        return;
      }
    }

    setState(() {
      _locationGranted = true;
      _logs += 'Разрешение на местоположение получено.\n';
    });
  }

  Future<void> _scanWiFiNetworks() async {
    setState(() {
      _isScanning = true;
      _logs += 'Начало сканирования Wi-Fi...\n';
    });

    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        _showErrorDialog('Сканирование Wi-Fi недоступно: $canScan.');
        setState(() {
          _isScanning = false;
          _logs += 'Сканирование не возможно: $canScan.\n';
        });
        return;
      }

      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      setState(() {
        _wifiList = results;
        _logs += 'Сканирование завершено. Найдено ${results.length} сетей.\n';
      });
    } catch (e) {
      _showErrorDialog('Ошибка сканирования Wi-Fi: $e');
      setState(() {
        _logs += 'Ошибка сканирования: $e\n';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
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
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isScanning ? null : _scanWiFiNetworks,
                    child: Text(
                      _isScanning ? 'Сканирование...' : 'Сканировать Wi-Fi',
                    ),
                  ),
                  SizedBox(height: 20),
                  _wifiList.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _wifiList.length,
                            itemBuilder: (context, index) {
                              final wifi = _wifiList[index];
                              return ListTile(
                                title: Text(wifi.ssid),
                                subtitle: Text(
                                  'Сигнал: ${wifi.level} dBm',
                                ),
                              );
                            },
                          ),
                        )
                      : Text('Нет доступных сетей Wi-Fi'),
                  SizedBox(height: 20),
                  Text(
                    'Логи:\n$_logs', // Отображаем логи на экране
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.left,
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
