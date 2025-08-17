// lib/modules/parent/child_stats_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_prueba/modules/parent/guage_widget.dart';

class ChildStatsPage extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ChildStatsPage({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Extracción segura de los datos del JSON
    final usageStats = stats['usageStats'] as Map<String, dynamic>;
    final screenTime = usageStats['screenTime'] as int;
    final inappropriateLanguage = usageStats['inappropriateLanguage'] as int;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas del Hijo')),
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, bc) {
            final isWide = bc.maxWidth >= 900;
            final pad = EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 20,
            );

            return SingleChildScrollView(
              padding: pad,
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  // Usa el valor real de 'screenTime'
                  SizedBox(
                    width: isWide ? (bc.maxWidth - 72) / 2 : bc.maxWidth - 32,
                    child: GaugeLive(
                      value: screenTime.toDouble(),
                      titleBottom: 'TIEMPO EN PANTALLA',
                    ),
                  ),
                  // Usa el valor real de 'inappropriateLanguage'
                  SizedBox(
                    width: isWide ? (bc.maxWidth - 72) / 2 : bc.maxWidth - 32,
                    child: GaugeLive(
                      value: inappropriateLanguage.toDouble(),
                      titleBottom: 'LENGUAJE INAPROPIADO',
                      legend: const [
                        (
                          Color(0xFF2ECC71),
                          'Bajo (0–10%)',
                          'Casi sin palabras inapropiadas.',
                        ),
                        (
                          Color(0xFF29B6F6),
                          'Moderado (10–25%)',
                          'Ocasional; mantener observación.',
                        ),
                        (
                          Color(0xFFF39C12),
                          'Alto (25–50%)',
                          'Frecuente; activar filtros/alertas.',
                        ),
                        (
                          Color(0xFF7E57C2),
                          'Crítico (50–75%)',
                          'Muy común; intervenir.',
                        ),
                        (
                          Color(0xFFF04B3A),
                          'Severo (75–100%)',
                          'Abuso constante; bloquear y revisar.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
