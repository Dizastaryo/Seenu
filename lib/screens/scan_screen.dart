import 'package:flutter/material.dart';
import 'package:wifi_flutter/wifi_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<Widget> _wifiNetworks = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Scanner'),
      ),
      body: Center(
        child: ListView.builder(
          itemBuilder: (context, index) => _wifiNetworks[index],
          itemCount: _wifiNetworks.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Check for location permission
          var status = await Permission.location.status;
          if (!status.isGranted) {
            // Request location permission if not granted
            status = await Permission.location.request();
            if (!status.isGranted) {
              // Permission denied, exit the function
              return;
            }
          }

          final noPermissions = await WifiFlutter.promptPermissions();
          if (noPermissions) {
            return;
          }

          final networks = await WifiFlutter.wifiNetworks;
          setState(() {
            _wifiNetworks = networks
                .map((network) => Text(
                    "SSID: ${network.ssid} - Strength: ${network.rssi} - Secure: ${network.isSecure}"))
                .toList();
          });
        },
        child: Icon(Icons.wifi),
      ),
    );
  }
}
