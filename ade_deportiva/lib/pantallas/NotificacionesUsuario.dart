import 'package:flutter/material.dart';
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
  int _currentIndex = 3;

  void _onItemTapped(int index) {
    if (index == 0) {
      navegarRapido(
        context,
        InicioUsuario(
          nombreCompleto: widget.nombreCompleto,
          idUsuario: widget.idUsuario, rol: widget.rol,
        ),
      );
    } else if (index == 1) {
      navegarRapido(
        context,
        CalendarioUsuario(
          idUsuario: widget.idUsuario,
          nombreCompleto: widget.nombreCompleto, rol: widget.rol,
        ),
      );
    } else if (index == 2) {
            if (widget.rol == "entrenador") {
              navegarRapido(
                context,
                RegistroEspacio(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto, rol: widget.rol,),
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
          nombreCompleto: widget.nombreCompleto, rol: widget.rol,
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

      /// DRAWER
      drawer: DrawerMenu(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto, rol: widget.rol,),

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
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle, size: 32),
                    onPressed: () {
                      navegarRapido(
                        context,
                        PerfilUsuario(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto, rol: widget.rol,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TARJETA 1
            _buildNotificacionCard(
              icon: Icons.notifications_active,
              title: "Aún no tienes entrenos activos",
              subtitle: "Registra tu primer entrenamiento.",
            ),

            /// TARJETA 2
            _buildNotificacionCard(
              icon: Icons.notifications_active,
              title: "¡Bienvenid@ a SIGEDEP!",
              subtitle:
                  "Ya puedes gestionar tus entrenamientos de forma rápida y sencilla.",
            ),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION
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
            icon: Icon(Icons.add_circle, size: 40),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }

  /// WIDGET REUTILIZABLE PARA TARJETAS
  Widget _buildNotificacionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A76B8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.yellow, size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}