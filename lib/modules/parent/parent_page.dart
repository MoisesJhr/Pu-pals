// parent_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_prueba/modules/parent/qr_scan_page.dart';
import 'package:flutter_prueba/modules/parent/child_stats_page.dart'; // <--- Importa tu nueva pantalla

class ParentPage extends StatelessWidget {
  const ParentPage({super.key});

  Future<void> _goScan(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<QrScanResult>(MaterialPageRoute(builder: (_) => const QrScanPage()));

    if (result == null) return;

    if (result.json != null) {
      final token = result.json!['token'];

      // Llama a la función que obtiene las estadísticas
      final stats = await _fetchChildStats(context, token);

      if (stats != null) {
        // Si las estadísticas se obtuvieron con éxito, navega a la pantalla de estadísticas
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChildStatsPage(stats: stats), // Pasa los datos
          ),
        );
      }
    } else {
      // Manejar el caso de QR no válido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código QR no es válido.')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchChildStats(
    BuildContext context,
    String token,
  ) async {
    final url = Uri.parse('https://0ec6053c367b.ngrok-free.app/parent/stats');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión con el servidor')),
      );
      return null;
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
