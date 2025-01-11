import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _BluetoothScanPageState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final Map<String, ScanResult> _foundDevices = {};
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });

    _flutterBlue.scan(allowDuplicates: true).listen((scanResult) {
      setState(() {
        _foundDevices[scanResult.device.id.id] = scanResult;
      });
    }, onError: (error) {
      setState(() {
        _isScanning = false;
      });
      debugPrint('Scan error: $error');
    });
  }

  void _stopScan() {
    _flutterBlue.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  void dispose() {
    _flutterBlue.stopScan();
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
              children: _foundDevices.values.map((result) {
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : 'Unknown Device'),
                  subtitle: Text(result.device.id.id),
                  trailing: Text('${result.rssi} dBm'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
