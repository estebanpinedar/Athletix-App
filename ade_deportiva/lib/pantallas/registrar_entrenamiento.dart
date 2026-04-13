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

  // =========================
  // DEPORTES
  // =========================
  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$api/deportes"));
    var data = json.decode(res.body);

    setState(() {
      deportes = data["deportes"] ?? [];
    });
  }

  // =========================
  // CATEGORIAS
  // =========================
  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$api/categorias"));
    var data = json.decode(res.body);

    setState(() {
      categorias = data["categorias"] ?? [];
    });
  }

  // =========================
  // EQUIPOS FILTRADOS (CORRECTO)
  // =========================
  Future<void> obtenerEquipos() async {
    if (idDeporte == null || idCategoria == null) return;

    print("URL: $api/equipos/disponibles/$idDeporte/$idCategoria"); // 👈 AQUÍ

    var res = await http.get(
      Uri.parse("$api/equipos/disponibles/$idDeporte/$idCategoria"),
    );

    var data = json.decode(res.body);

    print("Respuesta: $data"); // 👈 AQUÍ

    setState(() {
      equipos = data["data"] ?? [];
      idEquipo = null;
      dias = [];
      hora = null;
      grupoLleno = false;
    });
  }

  // =========================
  // HORARIO EQUIPO
  // =========================
  Future<void> obtenerHorario(int id) async {
    var res = await http.get(Uri.parse("$api/equipos/$id/horario"));

    var data = json.decode(res.body);

    setState(() {
      dias = List<String>.from(data["dias"] ?? []);
      hora = data["hora"];
    });
  }

  // =========================
  // INSCRIPCIÓN (CORRECTO BACKEND)
  // =========================
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

  // =========================
  // DROPDOWN
  // =========================
  Widget dropdown(
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
          return DropdownMenuItem(value: e[idKey], child: Text(e[textKey]));
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
              /// BACK
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
                "Inscripción a Equipos",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              /// DEPORTE
              dropdown("Deporte", idDeporte, deportes, "id_deporte", "nombre", (
                v,
              ) {
                setState(() {
                  idDeporte = v;
                  equipos = [];
                  idEquipo = null;
                });

                if (idDeporte != null && idCategoria != null) {
                  obtenerEquipos();
                }
              }),

              const SizedBox(height: 15),

              /// CATEGORIA
              dropdown(
                "Categoría",
                idCategoria,
                categorias,
                "id_categoria",
                "nombre",
                (v) {
                  setState(() {
                    idCategoria = v;
                    equipos = [];
                    idEquipo = null;
                  });

                  print(
                    "Deporte: $idDeporte - Categoria: $idCategoria",
                  ); // 👈 AQUÍ

                  if (idDeporte != null && idCategoria != null) {
                    obtenerEquipos();
                  }
                },
              ),

              const SizedBox(height: 15),

              /// EQUIPOS
              dropdown("Equipo", idEquipo, equipos, "id_equipo", "nombre", (
                v,
              ) async {
                setState(() {
                  idEquipo = v;
                });

                if (v != null) {
                  await obtenerHorario(v);
                }
              }),

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
                      const Text(
                        "Horario del equipo",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Días: ${dias.join(", ")}"),
                      Text("Hora: $hora"),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              /// FULL
              if (grupoLleno)
                const Text(
                  "⚠️ Grupo lleno",
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
                  child: const Text(
                    "Confirmar inscripción",
                    style: TextStyle(color: Colors.white),
                  ),
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
