import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrCodeScanner2 {
  static const MethodChannel _channel =
      const MethodChannel('com.lynkmyu.qr_code_scanner2');

  static Future<String?> imgScan(File file) async {
    if (file.existsSync() == false) {
      return null;
    }
    try {
      final rest =
          await _channel.invokeMethod("imgQrCode", {"file": file.path});
      return rest;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

class QrReaderView extends StatefulWidget {
  final Function(QrReaderViewController) callback;

  final int? autoFocusIntervalInMs;
  final bool? torchEnabled;
  final double? width;
  final double? height;

  const QrReaderView({
    Key? key,
    required this.callback,
    this.autoFocusIntervalInMs,
    this.torchEnabled = true,
    this.width = 500,
    this.height = 500,
  }) : super(key: key);

  @override
  _QrReaderViewState createState() => _QrReaderViewState();
}

class _QrReaderViewState extends State<QrReaderView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "com.lynkmyu.qr_code_scanner2.reader_view",
        creationParams: {
          "width": (widget.width! * window.devicePixelRatio).floor(),
          "height": (widget.height! * window.devicePixelRatio).floor(),
          "extra_focus_interval": widget.autoFocusIntervalInMs,
          "extra_torch_enabled": widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer()),
        ].toSet(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "com.lynkmyu.qr_code_scanner2.reader_view",
        creationParams: {
          "width": widget.width,
          "height": widget.height,
          "extra_focus_interval": widget.autoFocusIntervalInMs,
          "extra_torch_enabled": widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer()),
        ].toSet(),
      );
    } else {
      return Text('Lỗi');
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.callback(QrReaderViewController(id));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

typedef ReadChangeBack = void Function(String, List<Offset>);

class QrReaderViewController {
  final int id;
  final MethodChannel _channel;
  QrReaderViewController(this.id)
      : _channel = MethodChannel('com.lynkmyu.qr_code_scanner2.reader_view_$id') {
    _channel.setMethodCallHandler(_handleMessages);
  }
  ReadChangeBack? onQrBack;

  Future _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "onQRCodeRead":
        // ignore: deprecated_member_use
        final points = <Offset>[];
        if (call.arguments.containsKey("points")) {
          final pointsStrs = call.arguments["points"];
          for (String point in pointsStrs) {
            final a = point.split(",");
            points.add(
                Offset(double.tryParse(a.first)!, double.tryParse(a.last)!));
          }
        }

        this.onQrBack!(call.arguments["text"], points);
        break;
    }
  }

  Future<bool?> setFlashlight() async {
    return _channel.invokeMethod("flashlight");
  }

  Future startCamera(ReadChangeBack onQrBack) async {
    this.onQrBack = onQrBack;
    return _channel.invokeMethod("startCamera");
  }

  Future stopCamera() async {
    return _channel.invokeMethod("stopCamera");
  }
}
