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

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  /// 🔥 OBTENER DEPORTES
  Future<void> obtenerDeportes() async {
    var url = Uri.parse(
      "https://escuela-deportiva-project.onrender.com/deportes",
    );

    var response = await http.get(url);
    var data = json.decode(response.body);

    setState(() {
      deportes = data;
    });
  }

  /// 🔥 ACTUALIZAR ESPACIO
  Future<void> modificarEspacio() async {
    var url = Uri.parse(
      "https://escuela-deportiva-project.onrender.com/espacios/${widget.idEspacio}",
    );

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

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al modificar")),
      );
    }
  }

  Widget _input({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 52 : 0),
          child: Icon(icon, color: const Color(0xFF7C86A2)),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
        filled: true,
        fillColor: const Color(0xFF232C4A),
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
    );
  }

  Widget _dropdownDeportes() {
    return DropdownButtonFormField<int>(
      value: deporteSeleccionado,
      dropdownColor: const Color(0xFF232C4A),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.sports_soccer,
          color: Color(0xFF7C86A2),
        ),
        hintText: "Seleccionar deporte",
        hintStyle: const TextStyle(
          color: Color(0xFF7C86A2),
          fontSize: 15,
        ),
        filled: true,
        fillColor: const Color(0xFF232C4A),
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
      selectedItemBuilder: (context) {
        return deportes.map<Widget>((dep) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dep["nombre"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      items: deportes.map<DropdownMenuItem<int>>((d) {
        return DropdownMenuItem<int>(
          value: d["id_deporte"],
          child: Text(
            d["nombre"],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          deporteSeleccionado = value;
        });
      },
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFF7C86A2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2340),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF9FA8C3),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2340),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2F80ED),
                                          Color(0xFF1E5DBF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.edit_location_alt_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  "Modificar espacio",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Actualiza la información del espacio deportivo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF9FA8C3),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _input(
                                  controller: nombreController,
                                  icon: Icons.place_outlined,
                                  hint: "Nombre del espacio",
                                ),
                                const SizedBox(height: 15),
                                _dropdownDeportes(),
                                const SizedBox(height: 15),
                                _input(
                                  controller: descripcionController,
                                  icon: Icons.description_outlined,
                                  hint: "Descripción del espacio",
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  height: 55,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2F80ED),
                                          Color(0xFF1E5DBF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      onPressed: modificarEspacio,
                                      child: const Text(
                                        "Modificar",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF2E3A5F),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: const Color(0xFF232C4A),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(
                                        color: Color(0xFF9FA8C3),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Plataforma segura de gestión deportiva",
                        style: TextStyle(
                          color: Color(0xFF7C86A2),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
