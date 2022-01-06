import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner2/qrcode_reader_view.dart';
import 'package:qr_code_scanner2_example/test.dart';

class ScanViewDemo extends StatefulWidget {
  ScanViewDemo({Key? key}) : super(key: key);

  @override
  _ScanViewDemoState createState() => new _ScanViewDemoState();
}

class _ScanViewDemoState extends State<ScanViewDemo> {
  GlobalKey<QrcodeReaderViewState> _key = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: QrcodeReaderView(
        key: _key,
        onScan: onScan,
        headerWidget: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
    );
  }

  Future onScan(String data) async {
    if (data.length > 0) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => TestScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ảnh không hợp lệ. Vui lòng thử lại"),
      ));
      _key.currentState!.startScan();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
