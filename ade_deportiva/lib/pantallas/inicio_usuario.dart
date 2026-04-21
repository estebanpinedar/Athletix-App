import 'package:flutter/material.dart';
import 'screens.dart';
import '../widgets/curved_bottom_nav_bar.dart';

class InicioUsuario extends StatefulWidget {
  final String nombreCompleto;
  final int idUsuario;
  final String rol;

  const InicioUsuario({
    super.key,
    required this.nombreCompleto,
    required this.idUsuario,
    required this.rol,
  });

  @override
  State<InicioUsuario> createState() => _InicioUsuarioState();
}

class _InicioUsuarioState extends State<InicioUsuario> {
  int indiceSeleccionado = 0;

  void _onItemTapped(int index) {
    if (index == indiceSeleccionado) {
      return;
    }

    if (index == 1) {
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
  }

  /// 🔥 SOLO 2 NOMBRES
  String obtenerNombreCorto(String nombre) {
    List<String> partes = nombre.trim().split(" ");
    if (partes.length >= 2) {
      return "${partes[0]} ${partes[1]}";
    }
    return partes[0];
  }

  @override
  Widget build(BuildContext context) {
    String nombreCorto = obtenerNombreCorto(widget.nombreCompleto);

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

            /// CONTENIDO SCROLLEABLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    /// SALUDO
                    const Text(
                      "¡Hola!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nombreCorto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// BUSCADOR
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Buscar...",
                        hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF7C86A2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1B2340),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E3A5F),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F80ED),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// SECCIÓN TÍTULO
                    const Text(
                      "Accesos rápidos",
                      style: TextStyle(
                        color: Color(0xFF9FA8C3),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// TARJETA PRINCIPAL — REGISTRAR / VER EQUIPOS
                    widget.rol == "entrenador"
                        ? _tarjetaPrincipal(
                            titulo: "Ver Equipos",
                            subtitulo: "Gestiona tus equipos",
                            gradientColors: [
                              const Color(0xFF2F80ED),
                              const Color(0xFF1E5DBF),
                            ],
                            icono: Icons.emoji_events,
                            onTap: () {
                              navegarRapido(
                                context,
                                EquiposEntrenador(idUsuario: widget.idUsuario),
                              );
                            },
                          )
                        : _tarjetaPrincipal(
                            titulo: "Inscripción Equipos",
                            subtitulo: "¡Inscríbete aquí!",
                            gradientColors: [
                              const Color(0xFF2F80ED),
                              const Color(0xFF1E5DBF),
                            ],
                            icono: Icons.sports,
                            onTap: () {
                              navegarRapido(
                                context,
                                RegistrarEntrenamiento(
                                  idUsuario: widget.idUsuario,
                                  nombreCompleto: widget.nombreCompleto,
                                  rol: widget.rol,
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 16),

                    /// TARJETAS SECUNDARIAS — FILA
                    Row(
                      children: [
                        /// ESPACIOS / MIS EQUIPOS
                        widget.rol == "entrenador"
                            ? Expanded(
                                child: _tarjetaSecundaria(
                                  titulo: "Espacios",
                                  subtitulo: "Añade, modifica o elimina",
                                  gradientColors: [
                                    const Color(0xFFE84141),
                                    const Color(0xFFB52F2F),
                                  ],
                                  icono: Icons.place,
                                  onTap: () {
                                    navegarRapido(
                                      context,
                                      GestionEspacios(
                                        idUsuario: widget.idUsuario,
                                        nombreCompleto: widget.nombreCompleto,
                                        rol: widget.rol,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: _tarjetaSecundaria(
                                  titulo: "Mis Equipos",
                                  subtitulo: "Ver tus equipos activos",
                                  gradientColors: [
                                    const Color(0xFFE84141),
                                    const Color(0xFFB52F2F),
                                  ],
                                  icono: Icons.group,
                                  onTap: () {
                                    navegarRapido(
                                      context,
                                      MisEntrenamientos(
                                        idUsuario: widget.idUsuario,
                                        nombreCompleto: widget.nombreCompleto,
                                        rol: widget.rol,
                                      ),
                                    );
                                  },
                                ),
                              ),

                        const SizedBox(width: 14),

                        /// EQUIPOS / RESUMEN
                        Expanded(
                          child: _tarjetaSecundaria(
                            titulo: widget.rol == "entrenador"
                                ? "Ver Entrenamientos"
                                : "Resumen",
                            subtitulo: widget.rol == "entrenador"
                                ? "Consulta tus rutinas"
                                : "Ver tus próximas actividades",
                            gradientColors: [
                              const Color(0xFFCE943D),
                              const Color(0xFFA87020),
                            ],
                            icono: widget.rol == "entrenador"
                                ? Icons.fitness_center
                                : Icons.bar_chart,
                            onTap: () {
                              if (widget.rol == "entrenador") {
                                navegarRapido(
                                  context,
                                  VerEntrenamientosEntrenador(
                                    idUsuario: widget.idUsuario,
                                    nombreCompleto: widget.nombreCompleto,
                                    rol: widget.rol,
                                  ),
                                );
                              } else {
                                navegarRapido(
                                  context,
                                  Resumen(
                                    idUsuario: widget.idUsuario,
                                    nombreCompleto: widget.nombreCompleto,
                                    rol: widget.rol,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// HISTORIAL
                    GestureDetector(
                      onTap: () {
                        navegarRapido(
                          context,
                          Historial(
                            idUsuario: widget.idUsuario,
                            nombreCompleto: widget.nombreCompleto,
                            rol: widget.rol,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2340),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF2E3A5F)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
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
                                Icons.history,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Historial",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "Mira tu historial deportivo",
                                  style: TextStyle(
                                    color: Color(0xFF9FA8C3),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF7C86A2),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: indiceSeleccionado,
        onTap: _onItemTapped,
        rol: widget.rol,
      ),
    );
  }

  /// ─── WIDGET: TARJETA PRINCIPAL (ancho completo) ───────────────────────────
  Widget _tarjetaPrincipal({
    required String titulo,
    required String subtitulo,
    required List<Color> gradientColors,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icono, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  /// ─── WIDGET: TARJETA SECUNDARIA (media pantalla) ──────────────────────────
  Widget _tarjetaSecundaria({
    required String titulo,
    required String subtitulo,
    required List<Color> gradientColors,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitulo,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
