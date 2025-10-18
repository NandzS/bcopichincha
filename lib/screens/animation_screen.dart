import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import 'home_screen.dart';

class AnimationScreen extends StatefulWidget {
  final String usuarioCompleto;

  const AnimationScreen({super.key, required this.usuarioCompleto});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  final Random _random = Random();
  final int _numParticles = 40;
  final List<_Particle> _particles = [];

  String get primerNombre {
    if (widget.usuarioCompleto.isEmpty) return '';
    return widget.usuarioCompleto.split(' ')[0]; // solo primer nombre
  }

  @override
  void initState() {
    super.initState();

    // Animación del logo
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    // Partículas
    for (int i = 0; i < _numParticles; i++) {
      _particles.add(_Particle(random: _random));
    }

    // Redirigir después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      backgroundColor: AppColors.amarilloapp,
      body: Stack(
        children: [
          // Partículas
          ..._particles.map((p) => AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Positioned(
                    left: p.startX,
                    top: p.startY - (_controller.value * p.height),
                    child: Opacity(
                      opacity: 1 - _controller.value,
                      child: Icon(
                        Icons.star,
                        size: p.size,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  );
                },
              )),

          // Contenido central
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 
                Text(
                  'Bienvenido $primerNombre',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulMarino,
                  ),
                ),

                const SizedBox(height: 20),

                // Logo
                ScaleTransition(
                  scale: _scaleAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Image.asset(
                        'assets/images/bcopichincha_logoazul.png',
                        height: 50,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                
                const Text(
                  'Cargando preferencias...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.plomoapp,
                  ),
                ),
                const SizedBox(height: 16),

                
                const CircularProgressIndicator(
                  color: AppColors.azulMarino,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  double startX;
  double startY;
  double size;
  double height;

  _Particle({required Random random})
      : startX = random.nextDouble() * 300,
        startY = 400 + random.nextDouble() * 200,
        size = 5 + random.nextDouble() * 10,
        height = 200 + random.nextDouble() * 200;
}