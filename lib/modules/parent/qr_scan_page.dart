import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanResult {
  final String raw;
  final Map<String, dynamic>? json;
  QrScanResult({required this.raw, this.json});
}

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    torchEnabled: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _handled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller.stop();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _handled = true;

    QrScanResult result;

    try {
      final maybeJson = jsonDecode(value);
      if (maybeJson is Map<String, dynamic>) {
        final ok =
            maybeJson.containsKey('childId') &&
            maybeJson.containsKey('sessionToken');
        if (!ok) throw const FormatException('JSON sin campos requeridos');
        result = QrScanResult(raw: value, json: maybeJson);
      } else {
        result = QrScanResult(raw: value);
      }
    } catch (_) {
      const prefix = 'APP:CHILD:';
      if (!value.startsWith(prefix)) {
        setState(() {
          _handled = false;
          _error = 'El QR no es válido para esta app.';
        });
        return;
      }
      result = QrScanResult(raw: value);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR leído 👍')));
    Navigator.of(context).pop<QrScanResult>(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // El fondo negro de la cámara es necesario
      appBar: AppBar(
        title: const Text(
          'Escanear QR',
          style: TextStyle(color: Colors.white), // Título blanco
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(
          0.5,
        ), // AppBar semitransparente
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Linterna',
            onPressed: () => _controller.toggleTorch(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final torch = state.torchState;
                final isOn = torch == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white, // Icono blanco
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Cambiar cámara',
            onPressed: () => _controller.switchCamera(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final facing = state.cameraDirection;
                final back = facing == CameraFacing.back;
                return Icon(
                  back ? Icons.camera_rear : Icons.camera_front,
                  color: Colors.white, // Icono blanco
                );
              },
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const _ScannerOverlay(),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _ErrorBanner(
                message: _error!,
                onDismiss: () => setState(() => _error = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white70, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.redAccent.shade700.withOpacity(
        0.9,
      ), // Color semitransparente
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
