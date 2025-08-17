// lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_prueba/modules/home/home_page.dart'; // Asegúrate de que esta ruta sea correcta

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Duración de la animación
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Usa una curva de animación suave
    );

    _controller.forward().whenComplete(() {
      // Cuando la animación termina, navega a la siguiente pantalla
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Image.asset(
              'flutter_prueba/lib/assets/images/logo.png', // Tu logo
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
