import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MisEntrenamientos extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const MisEntrenamientos({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<MisEntrenamientos> createState() => _MisEntrenamientosState();
}

class _MisEntrenamientosState extends State<MisEntrenamientos> {
  final String api = "https://escuela-deportiva-project.onrender.com";

  List entrenamientos = [];

  @override
  void initState() {
    super.initState();
    obtenerMisInscripciones();
  }

  // =========================
  // OBTENER INSCRIPCIONES
  // =========================
  Future<void> obtenerMisInscripciones() async {
    var res = await http.get(
      Uri.parse("$api/mis-inscripciones/${widget.idUsuario}"),
    );

    var data = json.decode(res.body);

    setState(() {
      entrenamientos = data["data"] ?? [];
    });
  }

  // =========================
  // DARSE DE BAJA
  // =========================
  Future<void> darseDeBaja(int idEquipo) async {
    var res = await http.delete(
      Uri.parse("$api/inscripcion"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_usuario": widget.idUsuario,
        "id_equipo": idEquipo,
      }),
    );

    var data = json.decode(res.body);

    if (data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Te has dado de baja")),
      );

      obtenerMisInscripciones(); // 🔥 refrescar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["msg"] ?? "Error")),
      );
    }
  }

  // =========================
  // DIÁLOGO CONFIRMACIÓN
  // =========================
  void _mostrarDialogoBaja(Map entrenamiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Deseas darte de baja de este equipo?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  darseDeBaja(entrenamiento["id_equipo"]);
                },
                child: const Text("Confirmar",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // MENÚ OPCIONES
  // =========================
  void _onMenuOptionSelected(String option, Map entrenamiento) {
    if (option == "baja") {
      _mostrarDialogoBaja(entrenamiento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      body: SafeArea(
        child: Column(
          children: [
            /// BACK
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            /// TÍTULO
            const Text(
              "Mis Equipos",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// LISTA
            Expanded(
              child: entrenamientos.isEmpty
                  ? const Center(child: Text("No tienes inscripciones"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: entrenamientos.length,
                      itemBuilder: (context, index) {
                        final entrenamiento = entrenamientos[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.group,
                                size: 40,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 12),

                              /// INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${entrenamiento["deporte"]} - ${entrenamiento["categoria"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entrenamiento["nombre"],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// MENÚ
                              PopupMenuButton<String>(
                                onSelected: (value) =>
                                    _onMenuOptionSelected(
                                        value, entrenamiento),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: "baja",
                                    child: Text("Darme de baja"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}