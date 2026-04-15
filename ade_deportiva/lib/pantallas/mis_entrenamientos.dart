import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Set<int> abiertos = {};
  Map<int, List> horarios = {};
  Map<int, String> horas = {};

  @override
  void initState() {
    super.initState();
    obtenerMisInscripciones();
  }

  Future<void> obtenerMisInscripciones() async {
    var res = await http.get(
      Uri.parse("$api/mis-inscripciones/${widget.idUsuario}"),
    );

    var data = json.decode(res.body);

    setState(() {
      entrenamientos = data["data"] ?? [];
    });
  }

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
        backgroundColor: const Color(0xFF1B2340),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2E3A5F)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE84141).withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE84141),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "¿Deseas darte de baja?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Se eliminará tu inscripción de este equipo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7C86A2),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE84141), Color(0xFFB52F2F)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    darseDeBaja(entrenamiento["id_equipo"]);
                  },
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E3A5F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: const Color(0xFF232C4A),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Color(0xFF7C86A2)),
                ),
              ),
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
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2340),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E3A5F)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF9FA8C3),
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Mis Equipos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Consulta tus equipos inscritos y revisa sus horarios",
                style: TextStyle(
                  color: Color(0xFF9FA8C3),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: entrenamientos.isEmpty
                    ? Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2340),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF2E3A5F),
                            ),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.groups_rounded,
                                color: Color(0xFF7C86A2),
                                size: 46,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "No tienes inscripciones",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Cuando te inscribas a un equipo, aparecerá aquí.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF9FA8C3),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: entrenamientos.length,
                        itemBuilder: (context, index) {
                          final e = entrenamientos[index];
                          final abierto = abiertos.contains(e["id_equipo"]);

                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                if (abierto) {
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2340),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF2E3A5F),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2F80ED),
                                              Color(0xFF1E5DBF),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.groups_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${e["deporte"]} - ${e["categoria"]}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              e["nombre"],
                                              style: const TextStyle(
                                                color: Color(0xFF9FA8C3),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        abierto
                                            ? Icons.expand_less_rounded
                                            : Icons.expand_more_rounded,
                                        color: const Color(0xFF7C86A2),
                                      ),
                                      PopupMenuButton<String>(
                                        color: const Color(0xFF1B2340),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: const BorderSide(
                                            color: Color(0xFF2E3A5F),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                          color: Color(0xFF7C86A2),
                                        ),
                                        onSelected: (value) =>
                                            _onMenuOptionSelected(value, e),
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: "baja",
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.logout_rounded,
                                                  color: Color(0xFFE84141),
                                                  size: 18,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Darme de baja",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (abierto)
                                    Column(
                                      children: [
                                        const SizedBox(height: 12),
                                        const Divider(
                                          color: Color(0xFF2E3A5F),
                                        ),
                                        const SizedBox(height: 8),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Horario",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Días: ${(horarios[e["id_equipo"]] ?? []).join(", ")}",
                                            style: const TextStyle(
                                              color: Color(0xFF9FA8C3),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Hora: ${horas[e["id_equipo"]] ?? ""}",
                                            style: const TextStyle(
                                              color: Color(0xFF9FA8C3),
                                              fontSize: 13,
                                            ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
