import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'screens.dart';
import '../widgets/curved_bottom_nav_bar.dart';

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
      notificaciones.removeWhere((n) => n["id_notificacion"] == id);
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

  DateTime? _parseFechaServidor(dynamic raw) {
    if (raw == null) {
      return null;
    }

    final texto = raw.toString().trim();
    if (texto.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(texto).toLocal();
    } catch (_) {}

    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?$',
    ).firstMatch(texto);

    if (match == null) {
      return null;
    }

    final second = match.group(6) ?? '00';
    final isoBogota =
        '${match.group(1)}-${match.group(2)}-${match.group(3)}T${match.group(4)}:${match.group(5)}:$second-05:00';

    try {
      return DateTime.parse(isoBogota).toLocal();
    } catch (_) {
      return null;
    }
  }

  String formatearFechaNotificacion(dynamic fecha, dynamic fechaLocal) {
    final fechaParseada =
        _parseFechaServidor(fecha) ?? _parseFechaServidor(fechaLocal);

    if (fechaParseada == null) {
      return (fechaLocal ?? fecha ?? '').toString();
    }

    final ahora = DateTime.now();
    final inicioHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicioFecha = DateTime(
      fechaParseada.year,
      fechaParseada.month,
      fechaParseada.day,
    );
    final dias = inicioHoy.difference(inicioFecha).inDays;

    if (dias == 0) {
      return 'Hoy, ${DateFormat('HH:mm', 'es_CO').format(fechaParseada)}';
    }

    if (dias == 1) {
      return 'Ayer, ${DateFormat('HH:mm', 'es_CO').format(fechaParseada)}';
    }

    return DateFormat("d 'de' MMM, HH:mm", 'es_CO').format(fechaParseada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12192D),

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Builder(
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// MENÚ
                    GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2340),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFF9FA8C3),
                          size: 22,
                        ),
                      ),
                    ),

                    /// TÍTULO
                    const Text(
                      "Notificaciones",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// PERFIL
                    GestureDetector(
                      onTap: () {
                        navegarRapido(
                          context,
                          PerfilUsuario(
                            idUsuario: widget.idUsuario,
                            nombreCompleto: widget.nombreCompleto,
                            rol: widget.rol,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2340),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_circle,
                          color: Color(0xFF9FA8C3),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// SUBTÍTULO / CONTADOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${notificaciones.length} notificaciones",
                    style: const TextStyle(
                      color: Color(0xFF9FA8C3),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// LISTA
            Expanded(
              child: cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2F80ED),
                      ),
                    )
                  : notificaciones.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B2340),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.notifications_off_rounded,
                                  color: Color(0xFF7C86A2),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                "No hay notificaciones",
                                style: TextStyle(
                                  color: Color(0xFF7C86A2),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: notificaciones.length,
                          itemBuilder: (context, index) {
                            final n = notificaciones[index];
                            final String tipo = n["tipo"] ?? "";
                            final Color colorTipo = obtenerColor(tipo);
                            final IconData iconoTipo = obtenerIcono(tipo);

                            return Dismissible(
                              key: Key(n["id_notificacion"].toString()),
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) {
                                eliminarNotificacion(n["id_notificacion"]);
                              },
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                ),
                              ),
                              secondaryBackground: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                ),
                              ),
                              child: Container(
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
                                    /// ÍCONO CON COLOR SEGÚN TIPO
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: colorTipo.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: colorTipo.withOpacity(0.35),
                                        ),
                                      ),
                                      child: Icon(
                                        iconoTipo,
                                        color: colorTipo,
                                        size: 22,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    /// TEXTO
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n["mensaje"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                color: Color(0xFF7C86A2),
                                                size: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                formatearFechaNotificacion(
                                                  n["fecha"],
                                                  n["fecha_local"],
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF9FA8C3),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// FLECHA
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF7C86A2),
                                      size: 20,
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

      /// BOTTOM NAV
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        rol: widget.rol,
      ),
    );
  }
}
