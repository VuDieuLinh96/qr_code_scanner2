import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner2/qr_code_scanner2.dart';

class QrcodeReaderView extends StatefulWidget {
  final Widget? headerWidget;
  final Future Function(String) onScan;
  final double? scanBoxRatio;
  final Color? boxLineColor;
  final Widget? helpWidget;

  const QrcodeReaderView(
      {Key? key,
      this.headerWidget,
      required this.onScan,
      this.scanBoxRatio = 0.85,
      this.boxLineColor = Colors.cyanAccent,
      this.helpWidget})
      : super(key: key);

  @override
  QrcodeReaderViewState createState() => QrcodeReaderViewState();
}

class QrcodeReaderViewState extends State<QrcodeReaderView>
    with TickerProviderStateMixin {
  late QrReaderViewController _controller;
  late AnimationController _animationController;
  bool? openFlashlight;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    openFlashlight = false;
    _initAnimation();
  }

  void _initAnimation() {
    setState(() {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 1000));
    });
    _animationController
      ..addListener(_upState)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          _timer = Timer(Duration(seconds: 1), () {
            _animationController.reverse(from: 1.0);
          });
        } else if (state == AnimationStatus.dismissed) {
          _timer = Timer(Duration(seconds: 1), () {
            _animationController.forward(from: 0.0);
          });
        }
      });
    _animationController.forward(from: 0.0);
  }

  void _clearAnimation() {
    _timer?.cancel();
    // ignore: unnecessary_null_comparison
    if (_animationController != null) {
      _animationController.dispose();
    }
  }

  void _upState() {
    setState(() {});
  }

  void _onCreateController(QrReaderViewController controller) async {
    _controller = controller;
    _controller.startCamera(_onQrBack);
  }

  bool isScan = false;
  Future _onQrBack(data, _) async {
    if (isScan == true) return;
    isScan = true;
    stopScan();
    await widget.onScan(data);
  }

  void startScan() {
    isScan = false;
    _controller.startCamera(_onQrBack);
    _initAnimation();
  }

  void stopScan() {
    _clearAnimation();
    _controller.stopCamera();
  }

  Future<bool?> setFlashlight() async {
    openFlashlight = await _controller.setFlashlight();
    setState(() {});
    return openFlashlight;
  }

  @override
  Widget build(BuildContext context) {
    final flashOpen = Image.asset(
      "assets/flash_on.png",
      package: "qr_code_scanner2",
      width: 16,
      height: 16,
      color: Colors.white,
    );
    final flashClose = Image.asset(
      "assets/flash_off.png",
      package: "qr_code_scanner2",
      width: 16,
      height: 16,
      color: Colors.white,
    );
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final qrScanSize = constraints.maxWidth * widget.scanBoxRatio!;
        // ignore: unused_local_variable
        final mediaQuery = MediaQuery.of(context);
        if (constraints.maxHeight < qrScanSize * 1.5) {
          print("1.5");
        }
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: QrReaderView(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                callback: _onCreateController,
              ),
            ),
            if (widget.headerWidget != null) widget.headerWidget!,
            Positioned(
              top: (constraints.maxHeight - qrScanSize) / 3 + 30,
              width: constraints.maxWidth,
              child: Align(
                alignment: Alignment.center,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: widget.helpWidget ?? Text("Quét mã QR của sản phẩm"),
                ),
              ),
            ),
            Positioned(
              left: (constraints.maxWidth - qrScanSize) / 2,
              top: (constraints.maxHeight - qrScanSize) / 2,
              child: CustomPaint(
                painter: QrScanBoxPainter(
                  boxLineColor: widget.boxLineColor!,
                  animationValue: _animationController.value,
                  isForward:
                      _animationController.status == AnimationStatus.forward,
                ),
                child: SizedBox(
                  width: qrScanSize,
                  height: qrScanSize,
                ),
              ),
            ),
            Positioned(
              top: (constraints.maxHeight - qrScanSize) / 2 + qrScanSize + 10,
              width: constraints.maxWidth,
              child: Align(
                alignment: Alignment.center,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: widget.helpWidget ??
                      Text("Vui lòng căn mã vào giữa màn hình"),
                ),
              ),
            ),
            Positioned(
              top: (constraints.maxHeight - qrScanSize) / 2 + qrScanSize + 50,
              width: constraints.maxWidth,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: setFlashlight,
                    child: openFlashlight! ? flashOpen : flashClose,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _clearAnimation();
    super.dispose();
  }
}

class QrScanBoxPainter extends CustomPainter {
  final double animationValue;
  final bool isForward;
  final Color? boxLineColor;

  QrScanBoxPainter(
      {required this.animationValue,
      required this.isForward,
      this.boxLineColor})
      // ignore: unnecessary_null_comparison
      : assert(animationValue != null),
        // ignore: unnecessary_null_comparison
        assert(isForward != null);

  @override
  void paint(Canvas canvas, Size size) {
    final borderRadius = BorderRadius.all(Radius.circular(12)).toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRRect(
      borderRadius,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = new Path();
    // leftTop
    path.moveTo(0, 50);
    path.lineTo(0, 12);
    path.quadraticBezierTo(0, 0, 12, 0);
    path.lineTo(50, 0);
    // rightTop
    path.moveTo(size.width - 50, 0);
    path.lineTo(size.width - 12, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12);
    path.lineTo(size.width, 50);
    // rightBottom
    path.moveTo(size.width, size.height - 50);
    path.lineTo(size.width, size.height - 12);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 12, size.height);
    path.lineTo(size.width - 50, size.height);
    // leftBottom
    path.moveTo(50, size.height);
    path.lineTo(12, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 12);
    path.lineTo(0, size.height - 50);

    canvas.drawPath(path, borderPaint);

    canvas.clipRRect(
        BorderRadius.all(Radius.circular(12)).toRRect(Offset.zero & size));

    final linePaint = Paint();
    final lineSize = size.height * 0.45;
    final leftPress = (size.height + lineSize) * animationValue - lineSize;
    linePaint.style = PaintingStyle.stroke;
    linePaint.shader = LinearGradient(
      colors: [Colors.transparent, boxLineColor!],
      begin: isForward ? Alignment.topCenter : Alignment(0.0, 2.0),
      end: isForward ? Alignment(0.0, 0.5) : Alignment.topCenter,
    ).createShader(Rect.fromLTWH(0, leftPress, size.width, lineSize));
    for (int i = 0; i < size.height / 5; i++) {
      canvas.drawLine(
        Offset(
          i * 5.0,
          leftPress,
        ),
        Offset(i * 5.0, leftPress + lineSize),
        linePaint,
      );
    }
    for (int i = 0; i < lineSize / 5; i++) {
      canvas.drawLine(
        Offset(0, leftPress + i * 5.0),
        Offset(
          size.width,
          leftPress + i * 5.0,
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;

  @override
  bool shouldRebuildSemantics(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
