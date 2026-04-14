import 'dart:math';
import 'package:flutter/material.dart';
import 'screens.dart';

class PrincipalWidget extends StatefulWidget {
  const PrincipalWidget({super.key});

  @override
  State<PrincipalWidget> createState() => _PrincipalWidgetState();
}

class _PrincipalWidgetState extends State<PrincipalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🚀 NAVEGACIÓN RÁPIDA
  void navegarRapido(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12192D),
      body: Stack(
        children: [
          /// 🌌 FONDO ANIMADO
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),

          /// 📱 CONTENIDO
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                /// 🎯 ICONO PRINCIPAL
                Image.asset(
                  "assets/images/logo.png",
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                /// 🧠 TÍTULO
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "¡Bienvenido a Athetix!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ✏️ DESCRIPCIÓN
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Gestiona entrenamientos, jugadores y actividades de forma moderna y eficiente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9FA8C3), fontSize: 14),
                  ),
                ),

                const Spacer(),

                /// 🔘 BOTÓN REGISTRO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          navegarRapido(context, const RegistroUsuario());
                        },
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// 🔘 BOTÓN LOGIN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2340),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        navegarRapido(context, const IniciarSesion());
                      },
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// 🔒 TEXTO INFERIOR
                const Text(
                  "Plataforma segura de gestión deportiva",
                  style: TextStyle(color: Color(0xFF7C86A2), fontSize: 12),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌌 PARTÍCULAS ANIMADAS
class ParticlesPainter extends CustomPainter {
  final double progress;

  ParticlesPainter(this.progress);

  final List<Offset> baseParticles = List.generate(
    80, // 🔥 MÁS PARTÍCULAS
    (i) => Offset(
      (i * 37.0) % 500, // distribución menos repetitiva
      (i * 91.0) % 900,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F80ED).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < baseParticles.length; i++) {
      final p = baseParticles[i];

      /// movimiento suave infinito
      double x = (p.dx % size.width) +
          sin(progress * 2 * pi + i) * 25;

      double y = (p.dy % size.height) +
          cos(progress * 2 * pi + i) * 25;

      canvas.drawCircle(
        Offset(x, y),
        1.8 + (i % 3), // 🔥 tamaños variados
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}