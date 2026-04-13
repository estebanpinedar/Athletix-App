import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';

class NotificacionesUsuario extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const NotificacionesUsuario({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<NotificacionesUsuario> createState() =>
      _NotificacionesUsuarioState();
}

class _NotificacionesUsuarioState extends State<NotificacionesUsuario> {
  int _currentIndex = 3;

  final String api =
      "https://escuela-deportiva-project.onrender.com";

  List notificaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerNotificaciones();
  }

  // =========================
  // 🔥 OBTENER NOTIFICACIONES
  // =========================
  Future<void> obtenerNotificaciones() async {
    try {
      var res = await http.get(
        Uri.parse("$api/notificaciones/${widget.idUsuario}"),
      );

      var data = json.decode(res.body);

      setState(() {
        notificaciones = data["data"] ?? [];
        cargando = false;
      });

    } catch (e) {
      print("ERROR NOTIFICACIONES: $e");
      setState(() {
        cargando = false;
      });
    }
  }

  // =========================
  // ❌ ELIMINAR NOTIFICACION
  // =========================
  Future<void> eliminarNotificacion(int id) async {
    await http.delete(
      Uri.parse("$api/notificaciones/$id"),
    );

    setState(() {
      notificaciones.removeWhere((n) => n["id"] == id);
    });
  }

  // =========================
  // 🔥 NAVBAR
  // =========================
  void _onItemTapped(int index) {
    if (index == 0) {
      navegarRapido(
        context,
        InicioUsuario(
          nombreCompleto: widget.nombreCompleto,
          idUsuario: widget.idUsuario,
          rol: widget.rol,
        ),
      );
    } else if (index == 1) {
      navegarRapido(
        context,
        CalendarioUsuario(
          idUsuario: widget.idUsuario,
          nombreCompleto: widget.nombreCompleto,
          rol: widget.rol,
        ),
      );
    } else if (index == 2) {
      if (widget.rol == "entrenador") {
        navegarRapido(
          context,
          RegistroEspacio(
            idUsuario: widget.idUsuario,
            nombreCompleto: widget.nombreCompleto,
            rol: widget.rol,
          ),
        );
      } else {
        navegarRapido(
          context,
          RegistrarEntrenamiento(
            idUsuario: widget.idUsuario,
            nombreCompleto: widget.nombreCompleto,
            rol: widget.rol,
          ),
        );
      }
    } else if (index == 4) {
      navegarRapido(
        context,
        PerfilUsuario(
          idUsuario: widget.idUsuario,
          nombreCompleto: widget.nombreCompleto,
          rol: widget.rol,
        ),
      );
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // =========================
  // 🎨 ICONO SEGÚN TIPO
  // =========================
  IconData obtenerIcono(String tipo) {
    switch (tipo) {
      case "inscripcion":
        return Icons.check_circle;
      case "baja":
        return Icons.cancel;
      case "recordatorio":
        return Icons.access_time;
      case "equipo":
        return Icons.groups;
      case "espacio":
        return Icons.place;
      default:
        return Icons.notifications;
    }
  }

  // =========================
  // 🎨 COLOR SEGÚN TIPO
  // =========================
  Color obtenerColor(String tipo) {
    switch (tipo) {
      case "inscripcion":
        return Colors.green;
      case "baja":
        return Colors.red;
      case "recordatorio":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

      /// DRAWER
      drawer: DrawerMenu(
        idUsuario: widget.idUsuario,
        nombreCompleto: widget.nombreCompleto,
        rol: widget.rol,
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, size: 30),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const Text(
                    "Notificaciones",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle, size: 32),
                    onPressed: () {
                      navegarRapido(
                        context,
                        PerfilUsuario(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto,
                          rol: widget.rol,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// LISTA
            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : notificaciones.isEmpty
                      ? const Center(
                          child: Text("No hay notificaciones"),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notificaciones.length,
                          itemBuilder: (context, index) {
                            final n = notificaciones[index];

                            return Dismissible(
                              key: Key(n["id"].toString()),
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) {
                                eliminarNotificacion(n["id"]);
                              },

                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      obtenerIcono(n["tipo"] ?? ""),
                                      color:
                                          obtenerColor(n["tipo"] ?? ""),
                                      size: 35,
                                    ),
                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n["mensaje"] ?? "",
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            n["fecha"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      /// NAVBAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}