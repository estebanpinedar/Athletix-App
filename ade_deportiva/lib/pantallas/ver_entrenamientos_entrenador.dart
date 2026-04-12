import 'package:flutter/material.dart';

class VerEntrenamientosEntrenador extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const VerEntrenamientosEntrenador({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<VerEntrenamientosEntrenador> createState() =>
      _VerEntrenamientosEntrenadorState();
}

class _VerEntrenamientosEntrenadorState
    extends State<VerEntrenamientosEntrenador> {

  List entrenamientos = [];

  @override
  void initState() {
    super.initState();
    // 🔥 AQUÍ LUEGO LLAMAS TU API
    // obtenerEntrenamientos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

      appBar: AppBar(
        title: const Text("Entrenamientos"),
      ),

      body: entrenamientos.isEmpty
          ? const Center(
              child: Text("No hay entrenamientos disponibles"),
            )
          : ListView.builder(
              itemCount: entrenamientos.length,
              itemBuilder: (context, index) {
                var e = entrenamientos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/ver_entrenamientos.png",
                      width: 40,
                    ),
                    title: Text(e["nombre"] ?? "Entrenamiento"),
                    subtitle: Text(e["descripcion"] ?? ""),
                  ),
                );
              },
            ),
    );
  }
}