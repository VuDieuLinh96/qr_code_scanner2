import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner2_example/scanViewDemo.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  bool _showScanView = false;

  bool _openAction = false;

  Future<bool> permission() async {
    if (_openAction) return false;
    _openAction = true;
    var status = await Permission.camera.status;
    print(status);
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.camera.request();
      print(status);
    }

    if (status.isRestricted) {
      await Future.delayed(Duration(seconds: 3));
      openAppSettings();
      _openAction = false;
      return false;
    }

    if (!status.isGranted) {
      _openAction = false;
      return false;
    }
    _openAction = false;
    return true;
  }

  Future openScan(BuildContext context) async {
    if (false == await permission()) {
      return;
    }

    setState(() {
      _showScanView = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ScanViewDemo()));
            },
            child: Container(
              width: 100,
              height: 100,
              child: Text('QUet QR'),
            ),
          ),
        ),
      ),
    );
  }
}
