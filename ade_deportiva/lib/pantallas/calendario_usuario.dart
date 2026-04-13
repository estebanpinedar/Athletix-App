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

            /// 🔥 CALENDARIO BONITO
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
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

                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),

                  /// 🔴 punticos
                  markerDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),

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

            /// 🔥 LISTA DE ENTRENAMIENTOS
            Expanded(
              child: eventosSeleccionados.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay entrenamientos este día",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: eventosSeleccionados.length,
                      itemBuilder: (context, index) {
                        final e = eventosSeleccionados[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sports),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${e["nombre"]} - ${e["hora"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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

      /// NAV BAR
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

  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle, size: 40),
      label: "",
    ),
    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
  ],
),
    );
  }
}
