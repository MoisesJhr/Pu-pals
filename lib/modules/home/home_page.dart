import 'package:flutter/material.dart';
import '../../routes.dart'; // Importamos las rutas definidas

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o título principal
              const Text(
                "Bienvenido a la App",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Botón Soy Padre
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.parent);
                  },
                  child: const Text("👨‍👩‍👧 Soy Padre"),
                ),
              ),
              const SizedBox(height: 20),

              // Botón Soy Hijo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.child);
                  },
                  child: const Text("👦 Soy Hijo"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
