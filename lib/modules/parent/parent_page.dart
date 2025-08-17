import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_prueba/modules/parent/qr_scan_page.dart';

class ParentPage extends StatelessWidget {
  const ParentPage({super.key});

  Future<void> _goScan(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<QrScanResult>(MaterialPageRoute(builder: (_) => const QrScanPage()));

    if (result == null) return; // usuario volvió sin leer

    if (result.json != null) {
      final childId = result.json!['childId'];
      // final token = result.json!['sessionToken']; // úsalo si lo necesitas
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vinculado con hijo $childId')));
    } else {
      final previewLen = math.min(
        result.raw.length,
        40,
      ); // evita el warning de clamp
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR leído: ${result.raw.substring(0, previewLen)}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _goScan(context),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Leer QR'),
        ),
      ),
    );
  }
}
