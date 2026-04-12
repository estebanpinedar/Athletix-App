import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'screens.dart';

class CalendarioUsuario extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;

  const CalendarioUsuario({super.key, required this.idUsuario, required this.nombreCompleto});

  @override
  State<CalendarioUsuario> createState() => _CalendarioUsuarioState();
}

class _CalendarioUsuarioState extends State<CalendarioUsuario> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      drawer: DrawerMenu(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
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
                    /// MENU
                    IconButton(
                      icon: const Icon(Icons.menu, size: 30),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),

                    /// PERFIL
                    IconButton(
                      icon: const Icon(Icons.account_circle, size: 32),
                      onPressed: () {
                        navegarRapido(
                          context,
                          PerfilUsuario(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// CALENDARIO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.red),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            /// BOTÓN
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      /// 🔻 BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            navegarRapido(
              context,
              InicioUsuario(nombreCompleto: widget.nombreCompleto, idUsuario: widget.idUsuario, rol: '',),
            );
          } else if (index == 2) {
            navegarRapido(
              context,
              RegistrarEntrenamiento(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
            );
          } else if (index == 3) {
            navegarRapido(
              context,
              NotificacionesUsuario(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
            );
          } else if (index == 4) {
            navegarRapido(context, PerfilUsuario(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,));
          }
        },

        items: [
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
