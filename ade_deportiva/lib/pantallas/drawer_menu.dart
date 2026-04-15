import 'package:flutter/material.dart';
import 'screens.dart';

class DrawerMenu extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const DrawerMenu({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  void _mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2340),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2E3A5F)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ÍCONO
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.orange,
                size: 30,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "¿Está seguro que quiere cerrar sesión?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Tendrás que volver a iniciar sesión.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9FA8C3),
              ),
            ),

            const SizedBox(height: 24),

            /// BOTÓN CONFIRMAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
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
                    navegarRapido(context, const PrincipalWidget());
                  },
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// BOTÓN CANCELAR
            SizedBox(
              width: double.infinity,
              height: 46,
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
                  style: TextStyle(color: Color(0xFF9FA8C3), fontSize: 14),
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

  /// ─── WIDGET: ITEM DEL DRAWER ──────────────────────────────────────────────
  Widget _drawerItem({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2340),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E3A5F)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF2F80ED)).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                color: iconColor ?? const Color(0xFF2F80ED),
                size: 19,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              titulo,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor ?? const Color(0xFF7C86A2),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF12192D),
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2340),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2E3A5F)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// AVATAR
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// NOMBRE Y ROL
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nombreCompleto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2F80ED).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.rol[0].toUpperCase() +
                                widget.rol.substring(1),
                            style: const TextStyle(
                              color: Color(0xFF2F80ED),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// SEPARADOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Navegación",
                    style: TextStyle(
                      color: Color(0xFF9FA8C3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// OPCIONES
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  /// INICIO
                  _drawerItem(
                    icono: Icons.home_rounded,
                    titulo: "Inicio",
                    onTap: () => _navegar(
                      InicioUsuario(
                        nombreCompleto: widget.nombreCompleto,
                        idUsuario: widget.idUsuario,
                        rol: widget.rol,
                      ),
                    ),
                  ),

                  /// PERFIL
                  _drawerItem(
                    icono: Icons.person_rounded,
                    titulo: "Perfil de usuario",
                    onTap: () => _navegar(
                      PerfilUsuario(
                        idUsuario: widget.idUsuario,
                        nombreCompleto: widget.nombreCompleto,
                        rol: widget.rol,
                      ),
                    ),
                  ),

                  /// 🔥 OPCIONES SEGÚN ROL
                  if (widget.rol == "alumno") ...[
                    _drawerItem(
                      icono: Icons.add_box_rounded,
                      titulo: "Registrar entrenamiento",
                      onTap: () => _navegar(
                        RegistrarEntrenamiento(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto,
                          rol: widget.rol,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icono: Icons.fitness_center_rounded,
                      titulo: "Mis Equipos",
                      onTap: () => _navegar(
                        MisEntrenamientos(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto,
                          rol: widget.rol,
                        ),
                      ),
                    ),
                  ] else if (widget.rol == "entrenador") ...[
                    _drawerItem(
                      icono: Icons.visibility_rounded,
                      titulo: "Ver entrenamientos",
                      onTap: () => _navegar(
                        VerEntrenamientosEntrenador(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto,
                          rol: widget.rol,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icono: Icons.location_on_rounded,
                      titulo: "Espacios",
                      onTap: () => _navegar(
                        GestionEspacios(
                          idUsuario: widget.idUsuario,
                          nombreCompleto: widget.nombreCompleto,
                          rol: widget.rol,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icono: Icons.groups_rounded,
                      titulo: "Equipos",
                      onTap: () => _navegar(
                        EquiposEntrenador(idUsuario: widget.idUsuario),
                      ),
                    ),
                  ],

                  /// 🔥 COMUNES (AMBOS)
                  _drawerItem(
                    icono: Icons.calendar_month_rounded,
                    titulo: "Calendario",
                    onTap: () => _navegar(
                      CalendarioUsuario(
                        idUsuario: widget.idUsuario,
                        nombreCompleto: widget.nombreCompleto,
                        rol: widget.rol,
                      ),
                    ),
                  ),
                  _drawerItem(
                    icono: Icons.notifications_rounded,
                    titulo: "Notificaciones",
                    onTap: () => _navegar(
                      NotificacionesUsuario(
                        idUsuario: widget.idUsuario,
                        nombreCompleto: widget.nombreCompleto,
                        rol: widget.rol,
                      ),
                    ),
                  ),
                  _drawerItem(
                    icono: Icons.assignment_rounded,
                    titulo: "Resumen",
                    onTap: () => _navegar(
                      Resumen(
                        idUsuario: widget.idUsuario,
                        nombreCompleto: widget.nombreCompleto,
                        rol: widget.rol,
                      ),
                    ),
                  ),
                  _drawerItem(
                    icono: Icons.history_rounded,
                    titulo: "Historial",
                    onTap: () => _navegar(
                      Historial(
                        idUsuario: widget.idUsuario,
                        nombreCompleto: widget.nombreCompleto,
                        rol: widget.rol,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CERRAR SESIÓN
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: _drawerItem(
                icono: Icons.logout_rounded,
                titulo: "Cerrar sesión",
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent,
                onTap: _mostrarDialogoCerrarSesion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}