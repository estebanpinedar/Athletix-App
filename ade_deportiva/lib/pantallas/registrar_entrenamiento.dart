import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  State<RegistrarEntrenamiento> createState() =>
      _RegistrarEntrenamientoState();
}

class _RegistrarEntrenamientoState extends State<RegistrarEntrenamiento> {
  final String api =
      "https://escuela-deportiva-project.onrender.com";

  int? idDeporte;
  int? idCategoria;
  int? idEquipo;

  List deportes = [];
  List categorias = [];
  List equipos = [];

  Map<String, dynamic>? equipoSeleccionado;
  List<String> dias = [];
  String? hora;
  bool grupoLleno = false;

  @override
  void initState() {
    super.initState();
    obtenerDeportes();
    obtenerCategorias();
  }

  /// =========================
  /// DEPORTES
  /// =========================
  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$api/deportes"));
    var data = json.decode(res.body);

    setState(() {
      deportes = data["deportes"];
    });
  }

  /// =========================
  /// CATEGORIAS
  /// =========================
  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$api/categorias"));
    var data = json.decode(res.body);

    setState(() {
      categorias = data["categorias"];
    });
  }

  /// =========================
  /// EQUIPOS FILTRADOS
  /// =========================
  Future<void> obtenerEquipos() async {
    if (idDeporte == null || idCategoria == null) return;

    var res = await http.get(Uri.parse(
        "$api/equipos/filtrados?deporte=$idDeporte&categoria=$idCategoria"));

    var data = json.decode(res.body);

    setState(() {
      equipos = data["data"] ?? [];
      idEquipo = null;
      equipoSeleccionado = null;
      dias = [];
      hora = null;
      grupoLleno = false;
    });
  }

  /// =========================
  /// HORARIO EQUIPO
  /// =========================
  Future<void> obtenerHorario(int id) async {
    var res = await http.get(
      Uri.parse("$api/equipos/$id/horario"),
    );

    var data = json.decode(res.body);

    setState(() {
      dias = List<String>.from(data["dias"] ?? []);
      hora = data["hora"];
    });
  }

  /// =========================
  /// VERIFICAR CAPACIDAD
  /// =========================
  Future<void> verificarEquipo(int id) async {
    var res = await http.get(Uri.parse("$api/equipos/$id"));
    var data = json.decode(res.body);

    setState(() {
      grupoLleno = data["inscritos"] >= data["capacidad_maxima"];
    });
  }

  /// =========================
  /// INSCRIBIR
  /// =========================
  Future<void> inscribirse() async {
    if (grupoLleno) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ El grupo está lleno")),
      );
      return;
    }

    var res = await http.post(
      Uri.parse("$api/inscripciones"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_usuario": widget.idUsuario,
        "id_equipo": idEquipo,
      }),
    );

    var data = json.decode(res.body);

    if (data["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscripción realizada")),
      );
      Navigator.pop(context);
    }
  }

  /// =========================
  /// UI INPUT
  /// =========================
  Widget _dropdown(
    String hint,
    int? value,
    List items,
    String idKey,
    String textKey,
    Function(int?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint),
        items: items.map<DropdownMenuItem<int>>((e) {
          return DropdownMenuItem(
            value: e[idKey],
            child: Text(e[textKey]),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
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

              /// 🔙 BACK
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Image.asset("assets/images/logo.png", height: 140),

              const SizedBox(height: 10),

              const Text(
                "Inscribirse a Equipo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              /// DEPORTE
              _dropdown(
                "Deporte",
                idDeporte,
                deportes,
                "id_deporte",
                "nombre",
                (v) {
                  setState(() {
                    idDeporte = v;
                    idCategoria = null;
                    equipos = [];
                  });
                },
              ),

              const SizedBox(height: 15),

              /// CATEGORIA
              _dropdown(
                "Categoría",
                idCategoria,
                categorias,
                "id_categoria",
                "nombre",
                (v) {
                  setState(() {
                    idCategoria = v;
                  });
                  obtenerEquipos();
                },
              ),

              const SizedBox(height: 15),

              /// EQUIPOS
              _dropdown(
                "Equipo",
                idEquipo,
                equipos,
                "id_equipo",
                "nombre",
                (v) async {
                  setState(() {
                    idEquipo = v;
                    equipoSeleccionado = equipos
                        .firstWhere((e) => e["id_equipo"] == v);
                  });

                  await obtenerHorario(v!);
                  await verificarEquipo(v);
                },
              ),

              const SizedBox(height: 20),

              /// HORARIO
              if (dias.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Horario:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Días: ${dias.join(", ")}"),
                      Text("Hora: $hora"),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              /// ESTADO GRUPO
              if (grupoLleno)
                const Text(
                  "⚠️ El grupo está lleno",
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),

              /// BOTÓN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: inscribirse,
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
      ),
    );
  }
}