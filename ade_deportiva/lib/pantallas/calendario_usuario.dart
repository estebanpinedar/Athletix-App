import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';

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

class _CalendarioUsuarioState extends State<CalendarioUsuario> {
  final String api = "https://escuela-deportiva-project.onrender.com";

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, List> eventos = {}; // 🔥 eventos por día
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

    Map<String, List> temp = {};

    for (var e in data["data"]) {
      String dia = e["dia"]; // lunes, martes...

      if (!temp.containsKey(dia)) {
        temp[dia] = [];
      }

      temp[dia]!.add(e);
    }

    setState(() {
      eventos = temp;
    });
  }

  // =========================
  // CONVERTIR FECHA → DIA TEXTO
  // =========================
  String obtenerNombreDia(DateTime fecha) {
    const dias = [
      "lunes",
      "martes",
      "miercoles",
      "jueves",
      "viernes",
      "sabado",
      "domingo"
    ];

    return dias[fecha.weekday - 1];
  }

  // =========================
  // EVENTOS DEL DIA
  // =========================
  List obtenerEventosDelDia(DateTime fecha) {
    String dia = obtenerNombreDia(fecha);
    return eventos[dia] ?? [];
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
              child: Builder(
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
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
            ),

            /// 🔥 CALENDARIO EN CARD
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,

                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    eventosSeleccionados =
                        obtenerEventosDelDia(selectedDay);
                  });
                },

                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),

                  /// 🔥 indicador de eventos
                  markerDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),

                /// 🔥 MARCADORES
                eventLoader: (day) {
                  return obtenerEventosDelDia(day);
                },

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// 🔥 LISTA DE EVENTOS
            Expanded(
              child: eventosSeleccionados.isEmpty
                  ? const Center(
                      child: Text("No hay entrenamientos este día"),
                    )
                  : ListView.builder(
                      itemCount: eventosSeleccionados.length,
                      itemBuilder: (context, index) {
                        final e = eventosSeleccionados[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sports),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${e["nombre"]} - ${e["hora"]}",
                                ),
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

      /// NAV BAR (igual)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            navegarRapido(
              context,
              InicioUsuario(
                nombreCompleto: widget.nombreCompleto,
                idUsuario: widget.idUsuario,
                rol: widget.rol,
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}