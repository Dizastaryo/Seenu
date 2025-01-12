import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<String> _wifiSSIDs = [];

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
          itemCount: _wifiSSIDs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_wifiSSIDs[index]),
            );
          },
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

          // Load available Wi-Fi networks
          List<WifiNetwork?>? networks = await WiFiForIoTPlugin.loadWifiList();

          setState(() {
            // Extract only SSID from each network and display it
            _wifiSSIDs = networks
                    ?.map((network) => network?.ssid ?? 'Unknown')
                    .toList() ??
                [];
          });
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
