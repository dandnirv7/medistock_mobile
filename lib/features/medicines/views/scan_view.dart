import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

/// Barcode scanner view (Req 5.1–5.7).
///
/// Opens the device camera and reads EAN-13 / Code-128 barcodes.
/// Read-only — does not generate barcodes (Req 5.7).
///
/// Constructor parameters:
/// - [onBarcodeScanned]: called with the matched [MedicineModel] when
///   a barcode maps to a medicine in the system.
class ScanView extends StatefulWidget {
  const ScanView({super.key, required this.onBarcodeScanned});

  /// Callback fired when a barcode is detected AND a medicine is found.
  final void Function(MedicineModel medicine) onBarcodeScanned;

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  late final MobileScannerController _controller;

  /// Prevents processing multiple scans at once.
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.ean13, BarcodeFormat.code128],
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _processing = true;

    try {
      await _controller.stop();
    } catch (_) {
      // ignore stop errors — camera may already be stopped
    }

    try {
      // Look up medicine via search. The API uses `GET /medicines?search=<barcode>`.
      final repo = Get.find<MedicineRepository>();
      final result = await repo.getAll(
        query: MedicineQuery(search: rawValue, limit: 1),
      );

      final medicine = result.items.firstOrNull;

      if (medicine != null && mounted) {
        Get.back(); // close scanner
        widget.onBarcodeScanned(medicine);
      } else {
        // Not found — show snackbar and restart scanner (Req 5.5).
        SnackbarHelper.info('Obat tidak ditemukan');
        if (mounted) {
          setState(() {
            _processing = false;
          });
          await _controller.start();
        }
      }
    } catch (e) {
      SnackbarHelper.error('Gagal mencari obat');
      if (mounted) {
        setState(() {
          _processing = false;
        });
        await _controller.start();
      }
    }
  }

  void _onDetectError(Object error, StackTrace stackTrace) {
    if (error is MobileScannerException &&
        error.errorCode == MobileScannerErrorCode.permissionDenied) {
      // Camera permission denied (Req 5.6).
      SnackbarHelper.error(
        'Izin kamera diperlukan. Aktifkan di pengaturan.',
      );
      if (mounted) Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (ctx, state, _) {
                final torchOn = state.torchState == TorchState.on;
                return Icon(
                  torchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            tooltip: 'Senter',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen camera preview.
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            onDetectError: _onDetectError,
            errorBuilder: (ctx, error) {
              // Handle permission denied on camera init (Req 5.6).
              final isPermDenied =
                  error.errorCode == MobileScannerErrorCode.permissionDenied;
              if (isPermDenied) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  SnackbarHelper.error(
                    'Izin kamera diperlukan. Aktifkan di pengaturan.',
                  );
                  if (mounted) Get.back();
                });
              }
              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPermDenied
                            ? Icons.no_photography_outlined
                            : Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isPermDenied
                            ? 'Izin kamera diperlukan.\nAktifkan di pengaturan.'
                            : 'Kamera tidak tersedia.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scan window overlay with rectangular cutout.
          _ScanOverlay(),

          // Bottom hint label.
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke barcode obat',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),

          // Loading indicator while processing a scan.
          if (_processing)
            const Center(
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Darkened overlay with a transparent rectangular scan window.
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Central scan box: 260×140 dp.
        const boxW = 260.0;
        const boxH = 140.0;
        final left = (w - boxW) / 2;
        final top = (h - boxH) / 2 - 40;

        return CustomPaint(
          size: Size(w, h),
          painter: _OverlayPainter(
            scanRect: Rect.fromLTWH(left, top, boxW, boxH),
          ),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({required this.scanRect});

  final Rect scanRect;

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black54;

    // Draw four dark rectangles around the scan window.
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, scanRect.top), dimPaint);
    canvas.drawRect(
      Rect.fromLTRB(0, scanRect.bottom, size.width, size.height),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, scanRect.top, scanRect.left, scanRect.bottom),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(scanRect.right, scanRect.top, size.width, scanRect.bottom),
      dimPaint,
    );

    // Scan box border.
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(4)),
      borderPaint,
    );

    // Corner accent lines.
    const len = 20.0;
    final accentPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Top-left.
    canvas.drawLine(scanRect.topLeft, scanRect.topLeft.translate(len, 0), accentPaint);
    canvas.drawLine(scanRect.topLeft, scanRect.topLeft.translate(0, len), accentPaint);
    // Top-right.
    canvas.drawLine(scanRect.topRight, scanRect.topRight.translate(-len, 0), accentPaint);
    canvas.drawLine(scanRect.topRight, scanRect.topRight.translate(0, len), accentPaint);
    // Bottom-left.
    canvas.drawLine(scanRect.bottomLeft, scanRect.bottomLeft.translate(len, 0), accentPaint);
    canvas.drawLine(scanRect.bottomLeft, scanRect.bottomLeft.translate(0, -len), accentPaint);
    // Bottom-right.
    canvas.drawLine(scanRect.bottomRight, scanRect.bottomRight.translate(-len, 0), accentPaint);
    canvas.drawLine(scanRect.bottomRight, scanRect.bottomRight.translate(0, -len), accentPaint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect;
}
