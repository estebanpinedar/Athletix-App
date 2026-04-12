import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModificarEspacio extends StatefulWidget {
  final int idEspacio;
  final int idUsuario;
  final String nombre;
  final String descripcion;
  final int idDeporte;

  const ModificarEspacio({
    super.key,
    required this.idEspacio,
    required this.idUsuario,
    required this.nombre,
    required this.descripcion,
    required this.idDeporte,
  });

  @override
  State<ModificarEspacio> createState() => _ModificarEspacioState();
}

class _ModificarEspacioState extends State<ModificarEspacio> {

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  List deportes = [];
  int? deporteSeleccionado;

  @override
  void initState() {
    super.initState();

    nombreController.text = widget.nombre;
    descripcionController.text = widget.descripcion;
    deporteSeleccionado = widget.idDeporte;

    obtenerDeportes();
  }

  /// 🔥 OBTENER DEPORTES
  Future<void> obtenerDeportes() async {
    var url = Uri.parse("https://escuela-deportiva-project.onrender.com/deportes");

    var response = await http.get(url);
    var data = json.decode(response.body);

    setState(() {
      deportes = data;
    });
  }

  /// 🔥 ACTUALIZAR ESPACIO
  Future<void> modificarEspacio() async {
    var url = Uri.parse(
        "https://escuela-deportiva-project.onrender.com/espacios/${widget.idEspacio}");

    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
        "id_deporte": deporteSeleccionado,
      }),
    );

    var data = json.decode(response.body);

    if (data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Espacio modificado correctamente")),
      );

      Navigator.pop(context, true); // 🔥 refrescar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al modificar")),
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

              /// TITULO
              const Text(
                "Modificar Espacio",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// NOMBRE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stadium, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Nombre del espacio",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DEPORTE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: deporteSeleccionado,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Seleccionar deporte",
                        ),
                        items: deportes.map<DropdownMenuItem<int>>((d) {
                          return DropdownMenuItem(
                            value: d["id_deporte"],
                            child: Text(d["nombre"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            deporteSeleccionado = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DESCRIPCIÓN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Descripción",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// BOTÓN MODIFICAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: modificarEspacio,
                  child: const Text(
                    "Modificar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// CANCELAR
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