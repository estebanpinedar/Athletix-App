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
  State<NotificacionesUsuario> createState() => _NotificacionesUsuarioState();
}

class _NotificacionesUsuarioState extends State<NotificacionesUsuario> {
  final String api = "https://escuela-deportiva-project.onrender.com";

  int _currentIndex = 3;
  List notificaciones = [];

  @override
  void initState() {
    super.initState();
    cargarNotificaciones();
  }

  // =========================
  // CARGAR NOTIFICACIONES
  // =========================
  Future<void> cargarNotificaciones() async {
    var res = await http.get(
      Uri.parse("$api/notificaciones/${widget.idUsuario}"),
    );

    var data = json.decode(res.body);

    setState(() {
      notificaciones = data["data"] ?? [];
    });
  }

  // =========================
  // ELIMINAR NOTIFICACIÓN
  // =========================
  void eliminarNotificacion(int index) {
    setState(() {
      notificaciones.removeAt(index);
    });
  }

  // =========================
  // NAV
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Text(
                    "Notificaciones",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.notifications, size: 28),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// LISTA
            Expanded(
              child: notificaciones.isEmpty
                  ? const Center(
                      child: Text("No tienes notificaciones"),
                    )
                  : ListView.builder(
                      itemCount: notificaciones.length,
                      itemBuilder: (context, index) {
                        final n = notificaciones[index];

                        return Dismissible(
                          key: Key(n["id_notificacion"].toString()),
                          direction: DismissDirection.horizontal,

                          onDismissed: (direction) {
                            eliminarNotificacion(index);
                          },

                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),

                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),

                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.notifications,
                                    color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n["titulo"] ?? "",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(n["mensaje"] ?? ""),
                                      const SizedBox(height: 4),
                                      Text(
                                        n["fecha"] ?? "",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey),
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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}