import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModificarInformacionUsuario extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String documento;
  final String correo;

  const ModificarInformacionUsuario({
    super.key,
    required this.idUsuario,
    required this.nombre,
    required this.documento,
    required this.correo,
  });

  @override
  State<ModificarInformacionUsuario> createState() =>
      _ModificarInformacionUsuarioState();
}

class _ModificarInformacionUsuarioState
    extends State<ModificarInformacionUsuario> {
  late TextEditingController nombreController;
  late TextEditingController documentoController;
  late TextEditingController correoController;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: widget.nombre);
    documentoController = TextEditingController(text: widget.documento);
    correoController = TextEditingController(text: widget.correo);
  }

  Future<void> actualizarUsuario() async {
    var url = Uri.parse(
      "http://192.168.101.3:3000/usuarios/${widget.idUsuario}",
    );

    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombreController.text,
        "documento": documentoController.text,
        "correo": correoController.text,
      }),
    );

    var data = json.decode(response.body);

    if (data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados correctamente")),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al actualizar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

      appBar: AppBar(
        title: const Text("Modificar información"),
        backgroundColor: const Color(0xFFE8EEF2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),

              const SizedBox(height: 20),

              const Text(
                "Editar datos del usuario",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              /// NOMBRE
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre completo",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// DOCUMENTO
              TextField(
                controller: documentoController,
                decoration: InputDecoration(
                  labelText: "Documento",
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// CORREO
              TextField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const Spacer(),

              /// BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: actualizarUsuario,
                  child: const Text(
                    "Guardar cambios",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
