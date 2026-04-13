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

  // 🔥 EXPANSIÓN
  Set<int> abiertos = {};
  Map<int, List> horarios = {};
  Map<int, String> horas = {};

  @override
  void initState() {
    super.initState();
    obtenerMisInscripciones();
  }

  // =========================
  // TRAER INSCRIPCIONES
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
  // TRAER HORARIO
  // =========================
  Future<void> obtenerHorario(int idEquipo) async {
    var res = await http.get(
      Uri.parse("$api/equipos/$idEquipo/horario"),
    );

    var data = json.decode(res.body);

    setState(() {
      horarios[idEquipo] = data["dias"] ?? [];
      horas[idEquipo] = data["hora"] ?? "";
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

      obtenerMisInscripciones();
    }
  }

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
              "¿Deseas darte de baja?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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

              /// LOGO
              Image.asset("assets/images/logo.png", height: 140),

              const SizedBox(height: 10),

              /// TÍTULO
              const Text(
                "Mis Equipos",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              /// LISTA
              entrenamientos.isEmpty
                  ? const Text("No tienes inscripciones")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entrenamientos.length,
                      itemBuilder: (context, index) {
                        final e = entrenamientos[index];

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              if (abiertos.contains(e["id_equipo"])) {
                                abiertos.remove(e["id_equipo"]);
                              } else {
                                abiertos.add(e["id_equipo"]);
                              }
                            });

                            if (!horarios.containsKey(e["id_equipo"])) {
                              await obtenerHorario(e["id_equipo"]);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.groups, size: 35),
                                    const SizedBox(width: 12),

                                    /// INFO
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${e["deporte"]} - ${e["categoria"]}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(e["nombre"]),
                                        ],
                                      ),
                                    ),

                                    /// FLECHA
                                    Icon(
                                      abiertos.contains(e["id_equipo"])
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),

                                    /// MENÚ
                                    PopupMenuButton<String>(
                                      onSelected: (value) =>
                                          _onMenuOptionSelected(value, e),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: "baja",
                                          child:
                                              Text("Darme de baja"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                /// EXPANSIÓN
                                if (abiertos.contains(e["id_equipo"]))
                                  Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Divider(color: Colors.grey.shade400),
                                      const SizedBox(height: 8),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Horario:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Días: ${(horarios[e["id_equipo"]] ?? []).join(", ")}",
                                        ),
                                      ),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Hora: ${horas[e["id_equipo"]] ?? ""}",
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}