import 'package:flutter/material.dart';
import 'registro_usuario.dart';
import 'iniciar_sesion.dart';

class PrincipalWidget extends StatelessWidget {
  const PrincipalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// LOGO
                  Container(
                    width: 80,
                    height: 60,
                    alignment: Alignment.center,
                    child: Image.asset("assets/images/logo.png"),
                  ),

                  /// BOTÓN LOGIN
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  IniciarSesion(),
                        ),
                      );
                    },
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            /// IMAGEN SUPERIOR
            Container(
              width: double.infinity,
              height: 200,
              alignment: Alignment.center,
              child: Image.asset("assets/images/banner.png"),
            ),

            const SizedBox(height: 20),

            /// TÍTULO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Formación deportiva y disciplina al servicio de la comunidad.",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            /// DESCRIPCIÓN
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Este sistema te permite consultar horarios de entrenamiento, registrar deportistas y gestionar las actividades deportivas de forma fácil y organizada.\n\n"
                "Facilita la administración de la escuela deportiva y mejora la participación de los estudiantes en las diferentes disciplinas.",
                style: TextStyle(fontSize: 20),
              ),
            ),

            const Spacer(),

            /// ICONOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconFeature("optimizacion.png", "Optimización"),

                _iconFeature("educacion.png", "Educación"),

                _iconFeature("automatizacion.png", "Automatización"),
              ],
            ),

            const SizedBox(height: 60),

            /// BOTÓN REGISTRO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroUsuario(),
                      ),
                    );
                  },
                  child: const Text(
                    "Regístrate ahora",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ICONOS DE CARACTERÍSTICAS
  Widget _iconFeature(String assetName, String text) {
    return Column(
      children: [
        Image.asset(
          "assets/images/$assetName",
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 6),

        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
