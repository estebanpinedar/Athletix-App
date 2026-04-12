import 'package:flutter/material.dart';
import 'screens.dart';

class DrawerMenu extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;

  const DrawerMenu({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {

  void _mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Está seguro que quiere cerrar sesión?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// BOTÓN CONFIRMAR
            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  navegarRapido(context, const PrincipalWidget());
                },
                child: const Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// BOTÓN CANCELAR
            SizedBox(
              width: 150,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MÉTODO PARA NAVEGAR (más limpio)
  void _navegar(Widget pantalla) {
    Navigator.pop(context);
    navegarRapido(context, pantalla);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE8EEF2),
      child: Column(
        children: [

          /// HEADER
          Container(
            height: 100,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: const Text(
              "Menú",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          /// OPCIONES
          Expanded(
            child: ListView(
              children: [

                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Inicio"),
                  onTap: () => _navegar(
                    InicioUsuario(
                      nombreCompleto: widget.nombreCompleto,
                      idUsuario: widget.idUsuario,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Perfil de usuario"),
                  onTap: () => _navegar(
                    PerfilUsuario(
                      idUsuario: widget.idUsuario,
                      nombreCompleto: widget.nombreCompleto,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.add_box),
                  title: const Text("Registrar entrenamiento"),
                  onTap: () => _navegar(
                    RegistrarEntrenamiento(
                      idUsuario: widget.idUsuario,
                      nombreCompleto: widget.nombreCompleto,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text("Mis entrenamientos"),
                  onTap: () => _navegar(
                    MisEntrenamientos(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text("Calendario"),
                  onTap: () => _navegar(
                    CalendarioUsuario(
                      idUsuario: widget.idUsuario,
                      nombreCompleto: widget.nombreCompleto,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notificaciones"),
                  onTap: () => _navegar(
                    NotificacionesUsuario(
                      idUsuario: widget.idUsuario,
                      nombreCompleto: widget.nombreCompleto,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text("Resumen"),
                  onTap: () => _navegar(
                    Resumen(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Historial"),
                  onTap: () => _navegar(
                    Historial(idUsuario: widget.idUsuario, nombreCompleto: widget.nombreCompleto,),
                  ),
                ),
              ],
            ),
          ),

          /// CERRAR SESIÓN
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: _mostrarDialogoCerrarSesion,
            ),
          ),
        ],
      ),
    );
  }
}