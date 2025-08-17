import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class ChildPage extends StatefulWidget {
  const ChildPage({super.key});

  @override
  State<ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<ChildPage> {
  // Estado para manejar los datos del QR y el proceso de carga
  String? qrData; // Contendrá el JSON con childId y token
  bool isLoading = false; // Bandera para el estado de carga
  String? errorMessage; // Mensaje de error

  @override
  void initState() {
    super.initState();
    // Inicia el proceso de registro al cargar la página
    _registerChild();
  }

  // Función para registrar al niño en el servidor y obtener los datos del QR
  Future<void> _registerChild() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Tu URL de ngrok
    const String ngrokUrl = 'https://0ec6053c367b.ngrok-free.app';
    final Uri url = Uri.parse('$ngrokUrl/child/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // La solicitud fue exitosa
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String childId = responseBody['childId'];
        final String token = responseBody['token'];

        // Crea el JSON para el QR
        final qrJson = jsonEncode({'childId': childId, 'token': token});

        setState(() {
          qrData = qrJson;
          isLoading = false;
        });
      } else {
        // Error en la respuesta del servidor
        setState(() {
          errorMessage = 'Error del servidor: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      // Error de conexión
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Soy Niño"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Muestra este QR a tu padre",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // Muestra el QR o un indicador de carga/error
              if (isLoading)
                const CircularProgressIndicator()
              else if (errorMessage != null)
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                )
              else if (qrData != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData!,
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          "¡Ups! Algo salió mal con el QR.",
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                )
              else
                const Text(
                  "Generando código...",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              const SizedBox(height: 20),
              // Botón de reintento
              if (errorMessage != null)
                ElevatedButton(
                  onPressed: _registerChild,
                  child: const Text("Reintentar"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
