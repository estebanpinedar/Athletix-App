import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EquiposEntrenador extends StatefulWidget {
  final int idUsuario;

  const EquiposEntrenador({super.key, required this.idUsuario});

  @override
  State<EquiposEntrenador> createState() => _EquiposEntrenadorState();
}

class _EquiposEntrenadorState extends State<EquiposEntrenador> {
  List equipos = [];
  List equiposFiltrados = [];
  TextEditingController buscador = TextEditingController();

  final String api = "https://escuela-deportiva-project.onrender.com";

  @override
  void initState() {
    super.initState();
    cargarEquipos();
    buscador.addListener(filtrarEquipos);
  }

  Future<void> cargarEquipos() async {
    try {
      final res = await http.get(
        Uri.parse("$api/equipos/${widget.idUsuario}"),
      );

      final data = jsonDecode(res.body);

      setState(() {
        equipos = data["data"] ?? [];
        equiposFiltrados = equipos;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void filtrarEquipos() {
    final texto = buscador.text.toLowerCase();

    setState(() {
      equiposFiltrados = equipos.where((e) {
        return e["nombre"].toLowerCase().contains(texto);
      }).toList();
    });
  }

  void eliminarEquipo(int id) async {
    await http.delete(Uri.parse("$api/equipos/$id"));
    cargarEquipos();
  }

  void mostrarMenu(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Modificar"),
              onTap: () {
                Navigator.pop(context);
                // 🔥 luego implementamos editar
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Eliminar"),
              onTap: () {
                Navigator.pop(context);
                eliminarEquipo(id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

      body: SafeArea(
        child: Column(
          children: [

            // 🔍 BUSCADOR
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: buscador,
                decoration: InputDecoration(
                  hintText: "Buscar equipo...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 📋 LISTA
            Expanded(
              child: equiposFiltrados.isEmpty
                  ? const Center(child: Text("No hay equipos"))
                  : ListView.builder(
                      itemCount: equiposFiltrados.length,
                      itemBuilder: (context, index) {
                        final equipo = equiposFiltrados[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      equipo["nombre"],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      equipo["descripcion"] ?? "",
                                      style: const TextStyle(
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              // 🔥 MENÚ 3 PUNTOS
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () =>
                                    mostrarMenu(context, equipo["id_equipo"]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ➕ BOTÓN (como espacios)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () {
          // 🔥 luego agregamos crear equipo
        },
      ),
    );
  }
}