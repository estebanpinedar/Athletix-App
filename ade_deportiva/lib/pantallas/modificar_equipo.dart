import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModificarEquipo extends StatefulWidget {
  final int idEquipo;
  final String nombre;
  final String descripcion;
  final int idDeporte;
  final int idEspacio;
  final int idCategoria;
  final int capacidad;
  final int idUsuario;

  const ModificarEquipo({
    super.key,
    required this.idEquipo,
    required this.nombre,
    required this.descripcion,
    required this.idDeporte,
    required this.idEspacio,
    required this.idCategoria,
    required this.capacidad,
    required this.idUsuario,
  });

  @override
  State<ModificarEquipo> createState() => _ModificarEquipoState();
}

class _ModificarEquipoState extends State<ModificarEquipo> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final capacidadController = TextEditingController();

  List deportes = [];
  List espacios = [];
  List categorias = [];

  int? deporteSeleccionado;
  int? espacioSeleccionado;
  int? categoriaSeleccionada;

  final String baseUrl = "https://escuela-deportiva-project.onrender.com";

  /// 🔥 HORARIO
  List<String> dias = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
  ];

  List<String> diasSeleccionados = [];
  TimeOfDay? horaSeleccionada;

  @override
  void initState() {
    super.initState();

    nombreController.text = widget.nombre;
    descripcionController.text = widget.descripcion;
    capacidadController.text = widget.capacidad.toString();

    deporteSeleccionado = widget.idDeporte;
    espacioSeleccionado = widget.idEspacio;
    categoriaSeleccionada = widget.idCategoria;

    obtenerDeportes();
    obtenerCategorias();
    obtenerEspacios(widget.idDeporte);
  }

  /// 🔥 DEPORTES
  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$baseUrl/deportes"));
    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        deportes = data["deportes"];
      });
    }
  }

  /// 🔥 ESPACIOS
  Future<void> obtenerEspacios(int idDeporte) async {
    var res = await http.get(
      Uri.parse(
        "$baseUrl/espacios/deporte-entrenador/$idDeporte/${widget.idUsuario}",
      ),
    );

    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        espacios = List<Map<String, dynamic>>.from(data["data"]);
      });
    }
  }

  /// 🔥 CATEGORIAS
  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$baseUrl/categorias"));
    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        categorias = data["categorias"];
      });
    }
  }

  /// 🔥 MODIFICAR EQUIPO
  Future<void> modificarEquipo() async {
    if (nombreController.text.isEmpty ||
        deporteSeleccionado == null ||
        espacioSeleccionado == null ||
        categoriaSeleccionada == null ||
        capacidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    try {
      var res = await http.put(
        Uri.parse("$baseUrl/equipos/${widget.idEquipo}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombreController.text,
          "descripcion": descripcionController.text,
          "id_deporte": deporteSeleccionado,
          "id_espacio": espacioSeleccionado,
          "id_categoria": categoriaSeleccionada,
          "capacidad_maxima": int.parse(capacidadController.text),

          /// 🔥 HORARIO
          "dias": jsonEncode(diasSeleccionados),
          "hora": horaSeleccionada != null
              ? "${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}"
              : null,
        }),
      );

      var data = json.decode(res.body);

      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Equipo modificado correctamente")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Error al modificar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Image.asset("assets/images/logo.png", height: 150),

              const SizedBox(height: 10),

              const Text(
                "Modificar Equipo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              _input(Icons.groups, "Nombre del equipo", nombreController),

              const SizedBox(height: 20),

              _dropdown(
                Icons.sports,
                "Seleccionar deporte",
                deporteSeleccionado,
                deportes,
                (value) {
                  setState(() {
                    deporteSeleccionado = value;
                    espacioSeleccionado = null;
                    espacios = [];
                  });

                  if (value != null) {
                    obtenerEspacios(value);
                  }
                },
                "id_deporte",
                "nombre",
              ),

              const SizedBox(height: 20),

              _dropdown(
                Icons.location_on,
                "Seleccionar espacio",
                espacioSeleccionado,
                espacios,
                (value) {
                  setState(() {
                    espacioSeleccionado = value;
                  });
                },
                "id_espacio",
                "nombre",
              ),

              const SizedBox(height: 20),

              _dropdown(
                Icons.category,
                "Categoría",
                categoriaSeleccionada,
                categorias,
                (value) {
                  setState(() {
                    categoriaSeleccionada = value;
                  });
                },
                "id_categoria",
                "nombre",
              ),

              const SizedBox(height: 20),

              _input(
                Icons.people,
                "Capacidad máxima",
                capacidadController,
                isNumber: true,
              ),

              const SizedBox(height: 20),

              _input(
                Icons.description,
                "Descripción",
                descripcionController,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              /// 🔥 DÍAS
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Días de entrenamiento",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Column(
                children: dias.map((dia) {
                  return CheckboxListTile(
                    title: Text(dia),
                    value: diasSeleccionados.contains(dia),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          diasSeleccionados.add(dia);
                        } else {
                          diasSeleccionados.remove(dia);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              /// 🔥 HORA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (hora != null) {
                      setState(() {
                        horaSeleccionada = hora;
                      });
                    }
                  },
                  child: Text(
                    horaSeleccionada == null
                        ? "Seleccionar hora"
                        : "Hora: ${horaSeleccionada!.format(context)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: modificarEquipo,
                  child: const Text(
                    "Modificar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

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

  /// 🔧 INPUT
  Widget _input(
    IconData icon,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 DROPDOWN
  Widget _dropdown(
    IconData icon,
    String hint,
    int? value,
    List items,
    Function(int?) onChanged,
    String idKey,
    String textKey,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: items.any((item) => item[idKey] == value)
                  ? value
                  : null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
              items: items.map<DropdownMenuItem<int>>((item) {
                return DropdownMenuItem(
                  value: item[idKey],
                  child: Text(item[textKey]),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}