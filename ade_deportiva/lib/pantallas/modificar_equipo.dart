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

  const ModificarEquipo({
    super.key,
    required this.idEquipo,
    required this.nombre,
    required this.descripcion,
    required this.idDeporte,
    required this.idEspacio,
    required this.idCategoria,
    required this.capacidad,
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

  @override
  void initState() {
    super.initState();

    /// 🔥 cargar datos iniciales
    nombreController.text = widget.nombre;
    descripcionController.text = widget.descripcion;
    capacidadController.text = widget.capacidad.toString();

    deporteSeleccionado = widget.idDeporte;
    espacioSeleccionado = widget.idEspacio;
    categoriaSeleccionada = widget.idCategoria;

    obtenerDeportes();
    obtenerCategorias();
    obtenerEspacios(widget.idDeporte); // 🔥 importante
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

  /// 🔥 ESPACIOS (POR DEPORTE)
  Future<void> obtenerEspacios(int idDeporte) async {
    var res = await http.get(
      Uri.parse("$baseUrl/espacios/deporte/$idDeporte"),
    );

    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        espacios = data["data"];
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

  /// 🔥 ACTUALIZAR EQUIPO
  Future<void> modificarEquipo() async {
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
          const SnackBar(content: Text("Error al modificar")),
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

              /// 🔙 VOLVER
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              /// LOGO
              Image.asset("assets/images/logo.png", height: 150),

              const SizedBox(height: 10),

              const Text(
                "Modificar Equipo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// NOMBRE
              _input(Icons.groups, "Nombre del equipo", nombreController),

              const SizedBox(height: 20),

              /// DEPORTE
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

              /// ESPACIO
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

              /// CATEGORIA
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

              /// CAPACIDAD
              _input(Icons.people, "Capacidad máxima", capacidadController,
                  isNumber: true),

              const SizedBox(height: 20),

              /// DESCRIPCIÓN
              _input(Icons.description, "Descripción", descripcionController,
                  maxLines: 3),

              const SizedBox(height: 30),

              /// BOTÓN
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
  Widget _input(IconData icon, String hint, TextEditingController controller,
      {int maxLines = 1, bool isNumber = false}) {
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
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
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
              value: value,
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