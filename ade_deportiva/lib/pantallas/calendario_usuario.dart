import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';
import '../widgets/curved_bottom_nav_bar.dart';

class CalendarioUsuario extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const CalendarioUsuario({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<CalendarioUsuario> createState() => _CalendarioUsuarioState();
}

String normalizarDia(String texto) {
  return texto
      .toLowerCase()
      .replaceAll("á", "a")
      .replaceAll("é", "e")
      .replaceAll("í", "i")
      .replaceAll("ó", "o")
      .replaceAll("ú", "u")
      .trim();
}

class _CalendarioUsuarioState extends State<CalendarioUsuario> {
  final String api = "https://escuela-deportiva-project.onrender.com";

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, List> eventos = {};
  List eventosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    cargarEventos();
  }

  // =========================
  // CARGAR EVENTOS
  // =========================
  Future<void> cargarEventos() async {
    String url = widget.rol == "entrenador"
        ? "$api/calendario/entrenador/${widget.idUsuario}"
        : "$api/calendario/usuario/${widget.idUsuario}";

    var res = await http.get(Uri.parse(url));
    var data = json.decode(res.body);

    print("DATA BACKEND: $data");

    Map<String, List> temp = {};

    for (var e in data["data"]) {
      String dia = normalizarDia(e["dia"].toString());

      if (!temp.containsKey(dia)) {
        temp[dia] = [];
      }

      temp[dia]!.add(e);
    }

    print("MAPA EVENTOS: $temp");

    setState(() {
      eventos = temp;
    });
  }

  // =========================
  // FECHA → DIA TEXTO
  // =========================
  String obtenerNombreDia(DateTime fecha) {
    const dias = [
      "lunes",
      "martes",
      "miercoles",
      "jueves",
      "viernes",
      "sabado",
      "domingo",
    ];

    return dias[fecha.weekday - 1];
  }

  // =========================
  // EVENTOS DEL DIA
  // =========================
  List obtenerEventosDelDia(DateTime fecha) {
    final hoy = DateTime.now();

    // 🔥 NORMALIZAR (quitar horas)
    final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    // ❌ SI ES FECHA PASADA → NO MOSTRAR NADA
    if (fechaSinHora.isBefore(hoySinHora)) {
      return [];
    }

    // ✅ SI ES HOY O FUTURO → MOSTRAR
    String dia = obtenerNombreDia(fecha);
    return eventos[dia] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12192D),

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
                      "Calendario",
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

            /// CALENDARIO
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2340),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E3A5F)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,

                enabledDayPredicate: (day) {
                  final hoy = DateTime.now();
                  return !day.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
                },

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    eventosSeleccionados = obtenerEventosDelDia(selectedDay);
                  });
                },

                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Color(0xFFCDD5E0)),
                  weekendTextStyle: TextStyle(color: Color(0xFF9FA8C3)),
                  disabledTextStyle: TextStyle(color: Color(0xFF3A4560)),
                  outsideTextStyle: TextStyle(color: Color(0xFF3A4560)),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF2F80ED),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF1E5DBF),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Color(0xFFE84141),
                    shape: BoxShape.circle,
                  ),
                ),

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Color(0xFF9FA8C3),
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9FA8C3),
                  ),
                ),

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Color(0xFF7C86A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  weekendStyle: TextStyle(
                    color: Color(0xFF7C86A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TÍTULO SECCIÓN EVENTOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Entrenamientos del día",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// LISTA DE ENTRENAMIENTOS
            Expanded(
              child: eventosSeleccionados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2340),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.event_busy,
                              color: Color(0xFF7C86A2),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "No hay entrenamientos este día",
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
                      itemCount: eventosSeleccionados.length,
                      itemBuilder: (context, index) {
                        final e = eventosSeleccionados[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2340),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF2E3A5F)),
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
                                width: 46,
                                height: 46,
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
                                  Icons.sports,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e["nombre"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF7C86A2),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          e["hora"] ?? "",
                                          style: const TextStyle(
                                            color: Color(0xFF9FA8C3),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF7C86A2),
                                size: 14,
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

      /// BOTTOM NAV
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            return;
          }

          if (index == 0) {
            navegarRapido(
              context,
              InicioUsuario(
                nombreCompleto: widget.nombreCompleto,
                idUsuario: widget.idUsuario,
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
          } else if (index == 3) {
            navegarRapido(
              context,
              NotificacionesUsuario(
                idUsuario: widget.idUsuario,
                nombreCompleto: widget.nombreCompleto,
                rol: widget.rol,
              ),
            );
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
        },
        rol: widget.rol,
      ),
    );
  }
}
