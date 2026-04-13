import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';

class EquiposEntrenador extends StatefulWidget {
  final int idUsuario;

  const EquiposEntrenador({super.key, required this.idUsuario});

  @override
  State<EquiposEntrenador> createState() => _EquiposEntrenadorState();
}

class _EquiposEntrenadorState extends State<EquiposEntrenador> {
  List equipos = [];
  List equiposFiltrados = [];
  bool cargando = true;

  final TextEditingController buscadorController = TextEditingController();

  /// 🔥 OBTENER EQUIPOS
  Future<void> obtenerEquipos() async {
    try {
      var url = Uri.parse(
        "https://escuela-deportiva-project.onrender.com/equipos/${widget.idUsuario}",
      );

      var response = await http.get(url);
      var data = json.decode(response.body);

      if (data["success"]) {
        setState(() {
          equipos = data["data"];
          equiposFiltrados = equipos;
          cargando = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        cargando = false;
      });
    }
  }

  /// 🔥 ELIMINAR EQUIPO
  Future<void> eliminarEquipo(int idEquipo) async {
    try {
      var url = Uri.parse(
        "https://escuela-deportiva-project.onrender.com/equipos/$idEquipo",
      );

      var response = await http.delete(url);
      var data = json.decode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Equipo eliminado")));

        obtenerEquipos();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Error al eliminar")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// 🔥 CONFIRMAR ELIMINACIÓN
  void mostrarDialogoEliminar(int idEquipo) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Está seguro que quiere eliminar este equipo?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// BOTÓN CONFIRMAR
            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  eliminarEquipo(idEquipo); // 🔥 AQUÍ CAMBIA
                },
                child: const Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// BOTÓN CANCELAR
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  /// 🔍 BUSCAR
  void filtrar(String texto) {
    setState(() {
      equiposFiltrados = equipos.where((equipo) {
        return equipo["nombre"].toLowerCase().contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerEquipos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 VOLVER
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              /// TITULO
              const Text(
                "Equipos",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// 🔍 BUSCADOR
              TextField(
                controller: buscadorController,
                onChanged: filtrar,
                decoration: InputDecoration(
                  hintText: "Buscar equipo",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 LISTA
              Expanded(
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : equiposFiltrados.isEmpty
                    ? const Center(child: Text("No hay equipos registrados"))
                    : ListView.builder(
                        itemCount: equiposFiltrados.length,
                        itemBuilder: (context, index) {
                          var equipo = equiposFiltrados[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.groups),
                              title: Text(equipo["nombre"]),
                              subtitle: Text(equipo["descripcion"] ?? ""),

                              /// 🔥 MENÚ
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == "modificar") {
                                    navegarRapido(
                                      context,
                                      ModificarEquipo(
                                        idEquipo: equipo["id_equipo"],
                                        nombre: equipo["nombre"],
                                        descripcion: equipo["descripcion"],
                                        idDeporte: equipo["id_deporte"],
                                        idEspacio: equipo["id_espacio"],
                                        idCategoria: equipo["id_categoria"],
                                        capacidad: equipo["capacidad_maxima"],
                                        idUsuario: widget.idUsuario, // 🔥 ESTE ES CLAVE
                                      ),
                                    );
                                  } else if (value == "eliminar") {
                                    mostrarDialogoEliminar(equipo["id_equipo"]);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: "modificar",
                                    child: Text("Modificar"),
                                  ),
                                  PopupMenuItem(
                                    value: "eliminar",
                                    child: Text("Eliminar"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              /// 🔥 BOTÓN REGISTRAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistroEquipo(idUsuario: widget.idUsuario),
                      ),
                    ).then((_) => obtenerEquipos());
                  },
                  child: const Text(
                    "Registrar Equipo",
                    style: TextStyle(color: Colors.white),
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
