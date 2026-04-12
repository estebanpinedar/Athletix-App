import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';

class GestionEspacios extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const GestionEspacios({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<GestionEspacios> createState() => _GestionEspaciosState();
}

class _GestionEspaciosState extends State<GestionEspacios> {
  List espacios = [];
  List espaciosFiltrados = [];
  bool cargando = true;

  final TextEditingController buscadorController = TextEditingController();

  /// 🔥 OBTENER ESPACIOS DEL ENTRENADOR
  Future<void> obtenerEspacios() async {
    try {
      var url = Uri.parse(
        "https://escuela-deportiva-project.onrender.com/espacios/${widget.idUsuario}",
      );

      var response = await http.get(url);
      var data = json.decode(response.body);

      if (data["success"]) {
        setState(() {
          espacios = data["data"];
          espaciosFiltrados = espacios;
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

  /// 🔍 BUSCADOR
  void filtrar(String texto) {
    setState(() {
      espaciosFiltrados = espacios.where((espacio) {
        return espacio["nombre"].toLowerCase().contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerEspacios();
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),

              /// TITULO
              const Text(
                "Espacios",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// 🔍 BUSCADOR
              TextField(
                controller: buscadorController,
                onChanged: filtrar,
                decoration: InputDecoration(
                  hintText: "Buscar",
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
                    : espaciosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay espacios registrados",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: espaciosFiltrados.length,
                        itemBuilder: (context, index) {
                          var espacio = espaciosFiltrados[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.sports_soccer),
                              title: Text(espacio["nombre"]),
                              subtitle: Text(espacio["descripcion"] ?? ""),

                              /// 🔥 MENÚ 3 PUNTOS
                              trailing: PopupMenuButton(
                                onSelected: (value) {
                                  if (value == "modificar") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ModificarEspacio(
                                          idEspacio: espacio["id_espacio"],
                                          idUsuario: widget.idUsuario,
                                          nombre: espacio["nombre"],
                                          descripcion: espacio["descripcion"],
                                          idDeporte: espacio["id_deporte"],
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        obtenerEspacios(); // 🔥 refresca lista
                                      }
                                    });
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

              /// 🔥 BOTÓN REGISTRAR ESPACIO
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistroEspacio(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto,
                          rol: widget.rol,
                        ),
                      ),
                    ).then((_) {
                      obtenerEspacios(); // 🔥 REFRESCAR
                    });
                  },
                  child: const Text(
                    "Registrar Espacio",
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
