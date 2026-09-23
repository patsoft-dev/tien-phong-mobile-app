import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:remixicon/remixicon.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kích thước của ô vuông quét
    final scanWindowSize = MediaQuery.of(context).size.width * 0.7;
    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2 - 30,
      ),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Quét mã QR"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                if (state.cameraDirection == CameraFacing.front) {
                  return const Icon(
                    RemixIcons.camera_switch_line,
                    color: Colors.white,
                  );
                }
                return const Icon(
                  RemixIcons.camera_switch_fill,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera
          MobileScanner(
            controller: controller,
            scanWindow: scanWindow, // Chỉ quét trong vùng ô vuông
            onDetect: (capture) {
              if (isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    isScanned = true;
                  });
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),

          // 2. Lớp phủ làm tối bên ngoài + Ô vuông căn chỉnh ở giữa
          CustomPaint(
            size: Size.infinite,
            painter: ScannerOverlayPainter(scanWindow: scanWindow),
          ),

          // 3. Hướng dẫn phía dưới ô vuông
          Positioned(
            top: scanWindow.bottom + 24,
            left: 0,
            right: 0,
            child: const Text(
              "Căn chỉnh mã QR vào trong ô vuông",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget vẽ lớp phủ mờ xung quanh và 4 góc bo của ô vuông
class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  ScannerOverlayPainter({required this.scanWindow, this.borderRadius = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)),
      );

    // Màn mờ đen xung quanh
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Vẽ 4 góc khung căn chỉnh màu xanh sáng
    final borderPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final cornerLength = 24.0;
    final path = Path();

    // Góc trên - trái
    path.moveTo(scanWindow.left, scanWindow.top + cornerLength);
    path.lineTo(scanWindow.left, scanWindow.top + borderRadius);
    path.quadraticBezierTo(
      scanWindow.left,
      scanWindow.top,
      scanWindow.left + borderRadius,
      scanWindow.top,
    );
    path.lineTo(scanWindow.left + cornerLength, scanWindow.top);

    // Góc trên - phải
    path.moveTo(scanWindow.right - cornerLength, scanWindow.top);
    path.lineTo(scanWindow.right - borderRadius, scanWindow.top);
    path.quadraticBezierTo(
      scanWindow.right,
      scanWindow.top,
      scanWindow.right,
      scanWindow.top + borderRadius,
    );
    path.lineTo(scanWindow.right, scanWindow.top + cornerLength);

    // Góc dưới - phải
    path.moveTo(scanWindow.right, scanWindow.bottom - cornerLength);
    path.lineTo(scanWindow.right, scanWindow.bottom - borderRadius);
    path.quadraticBezierTo(
      scanWindow.right,
      scanWindow.bottom,
      scanWindow.right - borderRadius,
      scanWindow.bottom,
    );
    path.lineTo(scanWindow.right - cornerLength, scanWindow.bottom);

    // Góc dưới - trái
    path.moveTo(scanWindow.left + cornerLength, scanWindow.bottom);
    path.lineTo(scanWindow.left + borderRadius, scanWindow.bottom);
    path.quadraticBezierTo(
      scanWindow.left,
      scanWindow.bottom,
      scanWindow.left,
      scanWindow.bottom - borderRadius,
    );
    path.lineTo(scanWindow.left, scanWindow.bottom - cornerLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
