import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner2/qr_code_scanner2.dart';

class QrcodeReaderView extends StatefulWidget {
  final Widget? headerWidget;
  final Future Function(String) onScan;
  final double? scanBoxRatio;
  final Color? boxLineColor;
  final Widget? helpWidget;
  final bool isAnimation;

  const QrcodeReaderView(
      {Key? key,
      this.headerWidget,
      required this.onScan,
      this.scanBoxRatio = 0.85,
      this.boxLineColor = Colors.cyanAccent,
      this.isAnimation = false,
      this.helpWidget})
      : super(key: key);

  @override
  QrcodeReaderViewState createState() => QrcodeReaderViewState();
}

class QrcodeReaderViewState extends State<QrcodeReaderView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late QrReaderViewController _controller;
  late AnimationController _animationController;
  bool? openFlashlight;
  Timer? _timer;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    openFlashlight = false;
    _initAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    openFlashlight = false;
    setState(() {});
    super.didChangeDependencies();
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
    openFlashlight = false;
    setState(() {
      setFlashlight();
    });

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
            widget.isAnimation
                ? Positioned(
                    left: (constraints.maxWidth - qrScanSize) / 2,
                    top: (constraints.maxHeight - qrScanSize) / 2,
                    child: CustomPaint(
                      painter: QrScanBoxAnimationPainter(
                        boxLineColor: widget.boxLineColor!,
                        animationValue: _animationController.value,
                        isForward: _animationController.status ==
                            AnimationStatus.forward,
                      ),
                      child: SizedBox(
                        width: qrScanSize,
                        height: qrScanSize,
                      ),
                    ),
                  )
                : Positioned(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: QrScanBoxPainter(
                            borderColor: Colors.white,
                            borderRadius: 8,
                            borderLength: 32,
                            borderWidth: 4,
                          ),
                        ),
                      ),
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
              top: (constraints.maxHeight - qrScanSize) / 2 + qrScanSize + 20,
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
              top: (constraints.maxHeight - qrScanSize) / 2 + qrScanSize + 60,
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
    openFlashlight = false;
    super.dispose();
  }
}

class QrScanBoxAnimationPainter extends CustomPainter {
  final double animationValue;
  final bool isForward;
  final Color? boxLineColor;

  QrScanBoxAnimationPainter(
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
  bool shouldRepaint(QrScanBoxAnimationPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;

  @override
  bool shouldRebuildSemantics(QrScanBoxAnimationPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

const _CARD_ASPECT_RATIO = 3;
const _OFFSET_X_FACTOR = 0.05;

class QrScanBoxPainter extends ShapeBorder {
  const QrScanBoxPainter({
    this.borderColor = Colors.white,
    this.borderWidth = 8.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 12,
    this.borderLength = 32,
    this.cutOutBottomOffset = 0,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final offsetX = rect.width * _OFFSET_X_FACTOR;
    final cardWidth = rect.width - _CARD_ASPECT_RATIO * offsetX + 15;
    final cardHeight = rect.width - _CARD_ASPECT_RATIO * offsetX + 5;
    final offsetY = (rect.height - cardHeight) / 2;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + offsetX,
      rect.top + offsetY,
      cardWidth,
      cardHeight,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      // Draw top right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - borderLength,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + borderLength,
          topRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw top left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + borderLength,
          cutOutRect.top + borderLength,
          topLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw bottom right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - borderLength,
          cutOutRect.bottom - borderLength,
          cutOutRect.right,
          cutOutRect.bottom,
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // Draw bottom left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.bottom - borderLength,
          cutOutRect.left + borderLength,
          cutOutRect.bottom,
          bottomLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) {
    return QrScanBoxPainter(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
