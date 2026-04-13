import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroEquipo extends StatefulWidget {
  final int idUsuario;

  const RegistroEquipo({super.key, required this.idUsuario});

  @override
  State<RegistroEquipo> createState() => _RegistroEquipoState();
}

class _RegistroEquipoState extends State<RegistroEquipo> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final capacidadController = TextEditingController();

  final String baseUrl = "https://escuela-deportiva-project.onrender.com";

  List deportes = [];
  List espacios = [];
  List categorias = [];

  int? deporteSeleccionado;
  int? espacioSeleccionado;
  int? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    obtenerDeportes();
    obtenerCategorias();
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

  /// 🔥 ESPACIOS SEGÚN DEPORTE
  Future<void> obtenerEspacios(int idDeporte) async {
    try {
      var res = await http.get(
        Uri.parse("$baseUrl/espacios/deporte/$idDeporte/${widget.idUsuario}"),
      );

      var data = json.decode(res.body);

      print("ESPACIOS => $data"); // 🔥 AQUI

      if (data["success"]) {
        setState(() {
          espacios = data["data"];
        });
      }
    } catch (e) {
      print("Error espacios: $e");
    }
  }

  /// 🔥 CATEGORÍAS
  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$baseUrl/categorias"));
    var data = json.decode(res.body);

    print("CATEGORIAS => $data"); // 🔥 AQUÍ VA

    if (data["success"]) {
      setState(() {
        categorias = data["categorias"];
      });
    }
  }

  /// 🔥 REGISTRAR EQUIPO
  Future<void> registrarEquipo() async {
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
      var res = await http.post(
        Uri.parse("$baseUrl/equipos"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombreController.text,
          "descripcion": descripcionController.text,
          "id_deporte": deporteSeleccionado,
          "id_espacio": espacioSeleccionado,
          "id_categoria": categoriaSeleccionada,
          "capacidad_maxima": int.parse(capacidadController.text),
          "id_usuario": widget.idUsuario, // 🔥 CORREGIDO
        }),
      );

      var data = json.decode(res.body);

      if (data["success"]) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Equipo registrado")));

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
              /// 🔥 LOGO
              Center(child: Image.asset("assets/images/logo.png", height: 160)),

              const SizedBox(height: 10),

              const Text(
                "Registro de equipo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// 🔥 NOMBRE
              _input(Icons.groups, "Nombre del equipo", nombreController),

              const SizedBox(height: 20),

              /// 🔥 DEPORTE
              _dropdown(
                icon: Icons.sports,
                label: "Seleccionar deporte",
                value: deporteSeleccionado,
                items: deportes,
                onChanged: (value) {
                  setState(() {
                    deporteSeleccionado = value;
                    espacioSeleccionado = null;
                    espacios = [];
                  });

                  if (value != null) {
                    obtenerEspacios(value); // ✅ ya no da error
                  }
                },
                idKey: "id_deporte",
                textKey: "nombre",
              ),

              const SizedBox(height: 20),

              /// 🔥 ESPACIOS (DEPENDIENTE)
              _dropdown(
                icon: Icons.location_on,
                label: "Seleccionar espacio",
                value: espacioSeleccionado,
                items: espacios,
                onChanged: (value) {
                  setState(() {
                    espacioSeleccionado = value;
                  });
                },
                idKey: "id_espacio",
                textKey: "nombre",
              ),

              const SizedBox(height: 20),

              /// 🔥 CATEGORÍA
              _dropdown(
                icon: Icons.category,
                label: "Categoría",
                value: categoriaSeleccionada,
                items: categorias,
                onChanged: (value) {
                  setState(() {
                    categoriaSeleccionada = value;
                  });
                },
                idKey: "id_categoria",
                textKey: "nombre",
              ),

              const SizedBox(height: 20),

              /// 🔥 CAPACIDAD
              _input(
                Icons.people,
                "Capacidad máxima",
                capacidadController,
                isNumber: true,
              ),

              const SizedBox(height: 20),

              /// 🔥 DESCRIPCIÓN
              _input(
                Icons.description,
                "Descripción",
                descripcionController,
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              /// 🔥 BOTÓN REGISTRAR
              _boton("Registrar", registrarEquipo),

              const SizedBox(height: 15),

              /// 🔥 CANCELAR
              _cancelar(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 COMPONENTES REUTILIZABLES

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

  Widget _dropdown({
    required IconData icon,
    required String label,
    required int? value,
    required List items,
    required Function(int?) onChanged,
    required String idKey,
    required String textKey,
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
            child: DropdownButtonFormField<int>(
              value: value,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
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

  Widget _boton(String texto, Function() onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(texto, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _cancelar() {
    return SizedBox(
      width: 150,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancelar"),
      ),
    );
  }
}
