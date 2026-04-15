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

  @override
  void dispose() {
    nombreController.dispose();
    documentoController.dispose();
    correoController.dispose();
    super.dispose();
  }

  Future<void> actualizarUsuario() async {
    var url = Uri.parse(
      "https://escuela-deportiva-project.onrender.com/usuarios/${widget.idUsuario}",
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
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2340),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF9FA8C3),
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F80ED).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Editar datos del usuario",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Actualiza tu información personal",
                style: TextStyle(
                  color: Color(0xFF7C86A2),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F80ED),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "DATOS PERSONALES",
                      style: TextStyle(
                        color: Color(0xFF9FA8C3),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: nombreController,
                icono: Icons.person_rounded,
                label: "NOMBRE COMPLETO",
              ),

              const SizedBox(height: 14),

              _inputField(
                controller: documentoController,
                icono: Icons.credit_card_rounded,
                label: "DOCUMENTO",
              ),

              const SizedBox(height: 14),

              _inputField(
                controller: correoController,
                icono: Icons.email_rounded,
                label: "CORREO ELECTRÓNICO",
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E5DBF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: actualizarUsuario,
                    child: const Text(
                      "Guardar cambios",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icono,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7C86A2),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
            prefixIcon: Icon(icono, color: const Color(0xFF7C86A2)),
            filled: true,
            fillColor: const Color(0xFF1B2340),
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
        ),
      ],
    );
  }
}
