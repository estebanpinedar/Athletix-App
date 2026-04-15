import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Historial extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const Historial({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  final TextEditingController _searchController = TextEditingController();
  final String api = "https://escuela-deportiva-project.onrender.com";

  bool cargando = true;
  List historialItems = [];
  List historialFiltrado = [];
  Map<String, String> metricas = {};

  @override
  void initState() {
    super.initState();
    cargarHistorial();
    _searchController.addListener(_filtrarHistorial);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String obtenerNombreCorto(String nombre) {
    final partes = nombre.trim().split(" ");
    if (partes.length >= 2) {
      return "${partes[0]} ${partes[1]}";
    }
    return partes.first;
  }

  Future<void> cargarHistorial() async {
    setState(() {
      cargando = true;
    });

    try {
      if (widget.rol == "entrenador") {
        await _cargarHistorialEntrenador();
      } else {
        await _cargarHistorialAlumno();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (!mounted) return;
    setState(() {
      cargando = false;
    });
  }

  Future<void> _cargarHistorialAlumno() async {
    final responses = await Future.wait([
      http.get(Uri.parse("$api/notificaciones/${widget.idUsuario}")),
      http.get(Uri.parse("$api/mis-inscripciones/${widget.idUsuario}")),
    ]);

    final notificacionesData = json.decode(responses[0].body);
    final inscripcionesData = json.decode(responses[1].body);

    final notificaciones = List.from(notificacionesData["data"] ?? []);
    final inscripciones = List.from(inscripcionesData["data"] ?? []);

    final items = <Map<String, dynamic>>[];

    for (final n in notificaciones) {
      items.add({
        "titulo": n["mensaje"] ?? "Movimiento registrado",
        "subtitulo": n["fecha"]?.toString() ?? "Fecha no disponible",
        "icono": Icons.history_rounded,
        "color": const Color(0xFF2F80ED),
      });
    }

    for (final equipo in inscripciones.take(5)) {
      items.add({
        "titulo": equipo["nombre"] ?? "Equipo",
        "subtitulo": "Inscripción activa en ${equipo["deporte"] ?? "deporte"}",
        "icono": Icons.groups_rounded,
        "color": const Color(0xFFCE943D),
      });
    }

    setState(() {
      metricas = {
        "principal": notificaciones.length.toString(),
        "principalLabel": "Movimientos",
        "secundaria": inscripciones.length.toString(),
        "secundariaLabel": "Inscripciones",
        "tercera": widget.rol.isNotEmpty
            ? "${widget.rol[0].toUpperCase()}${widget.rol.substring(1)}"
            : "",

        "terceraLabel": "Rol actual",
      };
      historialItems = items;
      historialFiltrado = items;
    });
  }

  Future<void> _cargarHistorialEntrenador() async {
    final responses = await Future.wait([
      http.get(Uri.parse("$api/notificaciones/${widget.idUsuario}")),
      http.get(Uri.parse("$api/equipos/${widget.idUsuario}")),
      http.get(Uri.parse("$api/espacios/${widget.idUsuario}")),
    ]);

    final notificacionesData = json.decode(responses[0].body);
    final equiposData = json.decode(responses[1].body);
    final espaciosData = json.decode(responses[2].body);

    final notificaciones = List.from(notificacionesData["data"] ?? []);
    final equipos = List.from(equiposData["data"] ?? []);
    final espacios = List.from(espaciosData["data"] ?? []);

    final items = <Map<String, dynamic>>[];

    for (final n in notificaciones) {
      items.add({
        "titulo": n["mensaje"] ?? "Movimiento registrado",
        "subtitulo": n["fecha"]?.toString() ?? "Fecha no disponible",
        "icono": Icons.history_rounded,
        "color": const Color(0xFFE84141),
      });
    }

    for (final equipo in equipos.take(5)) {
      items.add({
        "titulo": equipo["nombre"] ?? "Equipo",
        "subtitulo": "Equipo gestionado por el entrenador",
        "icono": Icons.groups_rounded,
        "color": const Color(0xFF2F80ED),
      });
    }

    for (final espacio in espacios.take(5)) {
      items.add({
        "titulo": espacio["nombre"] ?? "Espacio",
        "subtitulo": "Espacio registrado en el sistema",
        "icono": Icons.place_rounded,
        "color": const Color(0xFFCE943D),
      });
    }

    setState(() {
      metricas = {
        "principal": notificaciones.length.toString(),
        "principalLabel": "Movimientos",
        "secundaria": equipos.length.toString(),
        "secundariaLabel": "Equipos creados",
        "tercera": espacios.length.toString(),
        "terceraLabel": "Espacios creados",
      };
      historialItems = items;
      historialFiltrado = items;
    });
  }

  void _filtrarHistorial() {
    final texto = _searchController.text.toLowerCase().trim();

    setState(() {
      if (texto.isEmpty) {
        historialFiltrado = historialItems;
      } else {
        historialFiltrado = historialItems.where((item) {
          final titulo = (item["titulo"] ?? "").toString().toLowerCase();
          final subtitulo = (item["subtitulo"] ?? "").toString().toLowerCase();
          return titulo.contains(texto) || subtitulo.contains(texto);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreCorto = obtenerNombreCorto(widget.nombreCompleto);

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
                "Historial",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.rol == "entrenador"
                    ? "Hola, $nombreCorto. Aquí puedes revisar los movimientos y registros de tu gestión."
                    : "Hola, $nombreCorto. Aquí puedes revisar tu actividad e inscripciones registradas.",
                style: const TextStyle(
                  color: Color(0xFF9FA8C3),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Buscar en el historial",
                  hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF7C86A2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1B2340),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E3A5F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF2F80ED),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (cargando)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                titulo: metricas["principalLabel"] ?? "Total",
                                valor: metricas["principal"] ?? "0",
                                icono: Icons.history_rounded,
                                color1: const Color(0xFF2F80ED),
                                color2: const Color(0xFF1E5DBF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                titulo: metricas["secundariaLabel"] ?? "Datos",
                                valor: metricas["secundaria"] ?? "0",
                                icono: Icons.folder_open_rounded,
                                color1: const Color(0xFFE84141),
                                color2: const Color(0xFFB52F2F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _wideStatCard(
                          titulo: metricas["terceraLabel"] ?? "Detalle",
                          valor: metricas["tercera"] ?? "0",
                          icono: widget.rol == "entrenador"
                              ? Icons.place_rounded
                              : Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle("Movimientos registrados"),
                        const SizedBox(height: 12),
                        if (historialFiltrado.isEmpty)
                          Container(
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
                                  Icons.history_toggle_off_rounded,
                                  color: Color(0xFF7C86A2),
                                  size: 48,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  "Historial vac�o",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tus movimientos y registros aparecerán aquí cuando estén disponibles.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF9FA8C3),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...historialFiltrado.map((item) {
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
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: (item["color"] as Color)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      item["icono"] as IconData,
                                      color: item["color"] as Color,
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
                                          item["titulo"] ?? "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item["subtitulo"] ?? "",
                                          style: const TextStyle(
                                            color: Color(0xFF9FA8C3),
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String texto) {
    return Row(
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
        Text(
          texto,
          style: const TextStyle(
            color: Color(0xFF9FA8C3),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.white, size: 22),
          const SizedBox(height: 18),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideStatCard({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2340),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2E3A5F)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: const Color(0xFF2F80ED), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF9FA8C3),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
