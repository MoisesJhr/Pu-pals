// lib/modules/parent/parent_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_prueba/modules/parent/qr_scan_page.dart';
import 'package:flutter_prueba/modules/parent/child_stats_page.dart';

// This widget is now a StatefulWidget to manage the changing text state.
class ParentPage extends StatefulWidget {
  const ParentPage({super.key});

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  // List of interesting facts about safety and communication with children.
  final List<String> _groomingFacts = [
    'Dedica tiempo de calidad a tu hijo cada día. Una comunicación abierta es la mejor prevención.',
    'Pregúntale a tu hijo sobre sus amigos en línea y los juegos que le gustan. Muestra interés genuino.',
    'Aprende sobre el ciberacoso y cómo identificarlo. Los niños necesitan saber que pueden contar contigo.',
    'No todos los extraños en línea son lo que parecen. Asegúrate de que tu hijo entienda los riesgos.',
    'Establece límites de tiempo y supervisión para el uso de la tecnología. La disciplina digital es clave.',
    'Fomenta actividades fuera de la pantalla. Un balance saludable ayuda a prevenir la adicción.',
    'Si algo te parece sospechoso, confía en tu instinto. Es mejor prevenir que lamentar.',
    'Recuérdale a tu hijo que no debe compartir información personal como su dirección o escuela en línea.',
    'La empatía es una herramienta poderosa. Enséñale a tu hijo a ser amable con los demás en el mundo digital.',
    'Mantén un diálogo constante y abierto. La confianza es la base de la seguridad digital.',
  ];

  late String _currentFact;
  late Timer _timer;
  int _factIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFact = _groomingFacts[_factIndex];
    // Starts a timer to change the fact every 8 seconds
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        _factIndex = (_factIndex + 1) % _groomingFacts.length;
        _currentFact = _groomingFacts[_factIndex];
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Ensures the timer is canceled to prevent memory leaks
    super.dispose();
  }

  Future<void> _goScan(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<QrScanResult>(MaterialPageRoute(builder: (_) => const QrScanPage()));

    if (result == null) return;

    if (result.json != null) {
      final token = result.json!['token'];

      final stats = await _fetchChildStats(context, token);

      if (stats != null) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ChildStatsPage(stats: stats)));
      }
    } else {
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
      appBar: AppBar(
        title: const Text('Soy Padre'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
            stops: const [0.3, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .end, // Aligns widgets to the end of the column
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "Leer QR" button
              ElevatedButton.icon(
                onPressed: () => _goScan(context),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  'Leer QR',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(
                height: 40,
              ), // Space between the button and the text
              // The widget with the curious fact is now lower and more compact
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white.withOpacity(
                  0.9,
                ), // Semi-transparent background
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _currentFact,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, // Smaller font size
                      fontStyle: FontStyle.italic,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
