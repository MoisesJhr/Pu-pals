// lib/modules/child/child_page.dart

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
  // State for handling QR data and the loading process
  String? qrData; // Will hold the JSON with childId and token
  bool isLoading = false; // Flag for loading state
  String? errorMessage; // Error message

  @override
  void initState() {
    super.initState();
    // Starts the registration process when the page loads
    _registerChild();
  }

  // Function to register the child on the server and get the QR data
  Future<void> _registerChild() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Your ngrok URL
    const String ngrokUrl = 'https://0ec6053c367b.ngrok-free.app';
    final Uri url = Uri.parse('$ngrokUrl/child/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // The request was successful
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String childId = responseBody['childId'];
        final String token = responseBody['token'];

        // Creates the JSON for the QR
        final qrJson = jsonEncode({'childId': childId, 'token': token});

        setState(() {
          qrData = qrJson;
          isLoading = false;
        });
      } else {
        // Server response error
        setState(() {
          errorMessage = 'Error del servidor: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      // Connection error
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soy Niño"),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent to show the gradient
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Extends the body behind the AppBar
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade100, // Gradient with a soft orange tone
              Colors.white,
            ],
            stops: const [0.3, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Muestra este QR a tu padre",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 60),
                if (isLoading)
                  const CircularProgressIndicator(
                    color: Colors.orange, // Indicator color to match the theme
                  )
                else if (errorMessage != null)
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  )
                else if (qrData != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                const SizedBox(height: 40),
                if (errorMessage != null)
                  ElevatedButton(
                    onPressed: _registerChild,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.orange.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Reintentar",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
