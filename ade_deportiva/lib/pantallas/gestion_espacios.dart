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

  /// ELIMINAR ESPACIO
  Future<void> eliminarEspacio(int idEspacio) async {
    try {
      var url = Uri.parse(
        "https://escuela-deportiva-project.onrender.com/espacios/$idEspacio?id_usuario=${widget.idUsuario}",
      );

      var response = await http.delete(url);

      var data = json.decode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Espacio eliminado")));

        obtenerEspacios();
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

  /// MODAL CONFIRMAR ELIMINACIÓN DE ESPACIO
  void mostrarDialogoEliminar(int idEspacio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2340),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2E3A5F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE84141).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Color(0xFFE84141),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "¿Eliminar espacio?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Esta acción no se puede deshacer.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C86A2),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE84141), Color(0xFFB52F2F)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      eliminarEspacio(idEspacio);
                    },
                    child: const Text(
                      "Confirmar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E3A5F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Color(0xFF7C86A2)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
  void dispose() {
    buscadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2340),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E3A5F)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF9FA8C3),
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Espacios",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
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
                    "Tus espacios registrados",
                    style: TextStyle(
                      color: Color(0xFF9FA8C3),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextField(
                controller: buscadorController,
                onChanged: filtrar,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Buscar espacio...",
                  hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7C86A2),
                  ),
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

              const SizedBox(height: 16),

              Expanded(
                child: cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2F80ED),
                        ),
                      )
                    : espaciosFiltrados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B2340),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF2E3A5F),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.sports_soccer_rounded,
                                    color: Color(0xFF7C86A2),
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No hay espacios registrados",
                                  style: TextStyle(
                                    color: Color(0xFF7C86A2),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: espaciosFiltrados.length,
                            itemBuilder: (context, index) {
                              var espacio = espaciosFiltrados[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B2340),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFF2E3A5F),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2F80ED),
                                            Color(0xFF1E5DBF),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.sports_soccer_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            espacio["nombre"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (espacio["descripcion"] != null &&
                                              espacio["descripcion"]
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              espacio["descripcion"],
                                              style: const TextStyle(
                                                color: Color(0xFF7C86A2),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    PopupMenuButton<String>(
                                      color: const Color(0xFF1B2340),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(
                                          color: Color(0xFF2E3A5F),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        color: Color(0xFF7C86A2),
                                      ),
                                      onSelected: (value) {
                                        if (value == "modificar") {
                                          navegarRapido(
                                            context,
                                            ModificarEspacio(
                                              idUsuario: widget.idUsuario,
                                              idEspacio: espacio["id_espacio"],
                                              nombre: espacio["nombre"],
                                              descripcion:
                                                  espacio["descripcion"],
                                              idDeporte:
                                                  espacio["id_deporte"],
                                            ),
                                          );
                                        } else if (value == "eliminar") {
                                          mostrarDialogoEliminar(
                                            espacio["id_espacio"],
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: "modificar",
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                color: Color(0xFF2F80ED),
                                                size: 18,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Modificar",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: "eliminar",
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_rounded,
                                                color: Color(0xFFE84141),
                                                size: 18,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Eliminar",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E5DBF).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                        obtenerEspacios();
                      });
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    label: const Text(
                      "Registrar Espacio",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
