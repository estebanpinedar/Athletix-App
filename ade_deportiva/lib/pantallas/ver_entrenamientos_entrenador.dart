import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final String api = "https://escuela-deportiva-project.onrender.com";

  List entrenamientos = [];
  bool cargando = true;

  String normalizarDia(String texto) {
    return texto
        .toLowerCase()
        .replaceAll("�", "a")
        .replaceAll("�", "e")
        .replaceAll("�", "i")
        .replaceAll("�", "o")
        .replaceAll("�", "u")
        .replaceAll("á", "a")
        .replaceAll("é", "e")
        .replaceAll("í", "i")
        .replaceAll("ó", "o")
        .replaceAll("ú", "u")
        .trim();
  }

  String obtenerNombreDiaActual() {
    const diasSemana = [
      "lunes",
      "martes",
      "miercoles",
      "jueves",
      "viernes",
      "sabado",
      "domingo",
    ];

    return diasSemana[DateTime.now().weekday - 1];
  }

  Future<void> obtenerEntrenamientos() async {
    try {
      final res = await http.get(
        Uri.parse("$api/calendario/entrenador/${widget.idUsuario}"),
      );

      final data = json.decode(res.body);
      final hoy = obtenerNombreDiaActual();

      if (data["success"] == true) {
        final lista = List.from(data["data"] ?? []);

        setState(() {
          entrenamientos = lista.where((e) {
            final dia = normalizarDia((e["dia"] ?? "").toString());
            return dia == hoy;
          }).toList();
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerEntrenamientos();
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
                "Entrenamientos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Consulta los entrenamientos programados para hoy",
                style: TextStyle(
                  color: Color(0xFF9FA8C3),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Entrenamientos del día",
                    style: TextStyle(
                      color: Color(0xFF9FA8C3),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2F80ED),
                        ),
                      )
                    : entrenamientos.isEmpty
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
                                    Icons.event_busy_rounded,
                                    color: Color(0xFF7C86A2),
                                    size: 46,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No hay entrenamientos para hoy",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Cuando tengas horarios programados para este día aparecerán aquí.",
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

                              return Container(
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
                                child: Row(
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
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.fitness_center_rounded,
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
                                            e["nombre"] ?? "Entrenamiento",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today_rounded,
                                                color: Color(0xFF7C86A2),
                                                size: 13,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                e["dia"] ?? "",
                                                style: const TextStyle(
                                                  color: Color(0xFF9FA8C3),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time_rounded,
                                                color: Color(0xFF7C86A2),
                                                size: 13,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                e["hora"] ?? "",
                                                style: const TextStyle(
                                                  color: Color(0xFF9FA8C3),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
      ),
    );
  }
}
