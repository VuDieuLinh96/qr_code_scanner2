import 'package:flutter/material.dart';
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
