import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrarEntrenamiento extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const RegistrarEntrenamiento({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<RegistrarEntrenamiento> createState() => _RegistrarEntrenamientoState();
}

class _RegistrarEntrenamientoState extends State<RegistrarEntrenamiento> {
  final String api = "https://escuela-deportiva-project.onrender.com";

  int? idDeporte;
  int? idCategoria;
  int? idEquipo;

  List deportes = [];
  List categorias = [];
  List equipos = [];

  List dias = [];
  String? hora;

  bool grupoLleno = false;

  @override
  void initState() {
    super.initState();
    obtenerDeportes();
    obtenerCategorias();
  }

  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$api/deportes"));
    var data = json.decode(res.body);

    setState(() {
      deportes = data["deportes"] ?? [];
    });
  }

  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$api/categorias"));
    var data = json.decode(res.body);

    setState(() {
      categorias = data["categorias"] ?? [];
    });
  }

  Future<void> obtenerEquipos() async {
    if (idDeporte == null || idCategoria == null) return;

    print("URL: $api/equipos/disponibles/$idDeporte/$idCategoria");

    var res = await http.get(
      Uri.parse("$api/equipos/disponibles/$idDeporte/$idCategoria"),
    );

    var data = json.decode(res.body);

    print("Respuesta: $data");

    setState(() {
      equipos = data["data"] ?? [];
      idEquipo = null;
      dias = [];
      hora = null;
      grupoLleno = false;
    });
  }

  Future<void> obtenerHorario(int id) async {
    var res = await http.get(Uri.parse("$api/equipos/$id/horario"));
    var data = json.decode(res.body);

    setState(() {
      dias = List<String>.from(data["dias"] ?? []);
      hora = data["hora"];
    });
  }

  Future<void> inscribirse() async {
    if (idEquipo == null) return;

    if (grupoLleno) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ El grupo está lleno")));
      return;
    }

    var res = await http.post(
      Uri.parse("$api/inscribir"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id_usuario": widget.idUsuario, "id_equipo": idEquipo}),
    );

    var data = json.decode(res.body);

    if (data["success"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Inscripción exitosa")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["msg"] ?? "Error")));
    }
  }

  Widget _dropdown(
    String hint,
    int? value,
    List items,
    String idKey,
    String textKey,
    Function(int?) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: const Color(0xFF232C4A),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF7C86A2)),
        filled: true,
        fillColor: const Color(0xFF232C4A),
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
      hint: Text(
        hint,
        style: const TextStyle(
          color: Color(0xFF7C86A2),
          fontSize: 15,
        ),
      ),
      selectedItemBuilder: (context) {
        return items.map<Widget>((e) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              e[textKey]?.toString() ?? "Sin nombre",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      items: items.map<DropdownMenuItem<int>>((e) {
        print("ITEM: $e");

        return DropdownMenuItem<int>(
          value: e[idKey] is int ? e[idKey] : int.tryParse(e[idKey].toString()),
          child: Text(
            e[textKey]?.toString() ?? "Sin nombre",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFF7C86A2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("LISTA EQUIPOS: $equipos");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2340),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF9FA8C3),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2340),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2F80ED),
                                          Color(0xFF1E5DBF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.app_registration_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  "Inscripción a equipos",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Selecciona el deporte, categoría y equipo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF9FA8C3),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _dropdown(
                                  "Seleccionar deporte",
                                  idDeporte,
                                  deportes,
                                  "id_deporte",
                                  "nombre",
                                  (v) {
                                    setState(() {
                                      idDeporte = v;
                                      equipos = [];
                                      idEquipo = null;
                                      dias = [];
                                      hora = null;
                                    });

                                    if (idDeporte != null &&
                                        idCategoria != null) {
                                      obtenerEquipos();
                                    }
                                  },
                                  Icons.sports_soccer_rounded,
                                ),
                                const SizedBox(height: 16),
                                _dropdown(
                                  "Seleccionar categoría",
                                  idCategoria,
                                  categorias,
                                  "id_categoria",
                                  "nombre",
                                  (v) {
                                    setState(() {
                                      idCategoria = v;
                                      equipos = [];
                                      idEquipo = null;
                                      dias = [];
                                      hora = null;
                                    });

                                    print(
                                      "Deporte: $idDeporte - Categoria: $idCategoria",
                                    );

                                    if (idDeporte != null &&
                                        idCategoria != null) {
                                      obtenerEquipos();
                                    }
                                  },
                                  Icons.category_outlined,
                                ),
                                const SizedBox(height: 16),
                                _dropdown(
                                  "Seleccionar equipo",
                                  idEquipo,
                                  equipos,
                                  "id_equipo",
                                  "nombre",
                                  (v) async {
                                    setState(() {
                                      idEquipo = v;
                                    });

                                    if (v != null) {
                                      await obtenerHorario(v);
                                    }
                                  },
                                  Icons.groups_rounded,
                                ),
                                const SizedBox(height: 18),
                                if (dias.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF232C4A),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFF2E3A5F),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month_rounded,
                                              color: Color(0xFF2F80ED),
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Horario del equipo",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Días: ${dias.join(", ")}",
                                          style: const TextStyle(
                                            color: Color(0xFF9FA8C3),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Hora: $hora",
                                          style: const TextStyle(
                                            color: Color(0xFF9FA8C3),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (dias.isNotEmpty) const SizedBox(height: 16),
                                if (grupoLleno)
                                  const Text(
                                    "⚠️ Grupo lleno",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (grupoLleno) const SizedBox(height: 16),
                                SizedBox(
                                  height: 55,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2F80ED),
                                          Color(0xFF1E5DBF),
                                        ],
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
                                      onPressed: inscribirse,
                                      child: const Text(
                                        "Confirmar inscripción",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF2E3A5F),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: const Color(0xFF232C4A),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(
                                        color: Color(0xFF9FA8C3),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Plataforma segura de gestión deportiva",
                        style: TextStyle(
                          color: Color(0xFF7C86A2),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
