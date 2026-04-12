import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroEspacio extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const RegistroEspacio({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol
  });

  @override
  State<RegistroEspacio> createState() => _RegistroEspacioState();
}

class _RegistroEspacioState extends State<RegistroEspacio> {

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  List deportes = [];
  int? deporteSeleccionado;

  final String baseUrl = "https://escuela-deportiva-project.onrender.com";

  @override
  void initState() {
    super.initState();
    obtenerDeportes();
  }

  /// 🔥 TRAER DEPORTES DESDE BD
  Future<void> obtenerDeportes() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/deportes"));
      var data = json.decode(response.body);

      if (data["success"]) {
        setState(() {
          deportes = data["deportes"];
        });
      }
    } catch (e) {
      print("Error deportes: $e");
    }
  }

  /// 🔥 REGISTRAR ESPACIO
  Future<void> registrarEspacio() async {

    if (nombreController.text.isEmpty || deporteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los campos")),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("$baseUrl/espacios"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombreController.text,
          "descripcion": descripcionController.text,
          "id_deporte": deporteSeleccionado,
          "id_usuario": widget.idUsuario,
        }),
      );

      var data = json.decode(response.body);

      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Espacio registrado")),
        );

        Navigator.pop(context, true);
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

              /// 🔥 LOGO
              Center(
                child: Image.asset("assets/images/logo.png", height: 160),
              ),
              const SizedBox(height: 10),

              /// 🔥 TITULO
              const Text(
                "Registro de espacio",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// 🔥 NOMBRE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, color: Colors.blue),
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

              /// 🔥 DEPORTE (DESDE BD)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: "Seleccionar deporte",
                        ),
                        value: deporteSeleccionado,
                        items: deportes.map<DropdownMenuItem<int>>((dep) {
                          return DropdownMenuItem(
                            value: dep["id_deporte"],
                            child: Text(dep["nombre"]),
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

              /// 🔥 DESCRIPCIÓN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: descripcionController,
                        maxLines: 3,
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

              /// 🔥 BOTON REGISTRAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: registrarEspacio,
                  child: const Text(
                    "Registrar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// 🔥 BOTON CANCELAR
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}