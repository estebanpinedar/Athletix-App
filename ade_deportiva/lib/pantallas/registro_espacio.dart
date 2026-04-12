import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroEspacio extends StatefulWidget {
  final int idUsuario;

  const RegistroEspacio({super.key, required this.idUsuario});

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

  /// 🔥 TRAER DEPORTES
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
          "id_entrenador": widget.idUsuario,
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
      appBar: AppBar(
        title: const Text("Registro de espacio"),
        backgroundColor: const Color(0xFFE8EEF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// NOMBRE
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.sports),
                hintText: "Nombre del espacio",
              ),
            ),

            const SizedBox(height: 15),

            /// DEPORTE
            DropdownButtonFormField<int>(
              value: deporteSeleccionado,
              hint: const Text("Selecciona deporte"),
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

            const SizedBox(height: 15),

            /// DESCRIPCION
            TextField(
              controller: descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.description),
                hintText: "Descripción",
              ),
            ),

            const SizedBox(height: 25),

            /// BOTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registrarEspacio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Text("Registrar"),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }
}