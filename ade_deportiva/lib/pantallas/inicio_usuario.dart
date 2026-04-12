import 'package:flutter/material.dart';
import 'screens.dart';

class InicioUsuario extends StatefulWidget {
  final String nombreCompleto;
  final int idUsuario;
  final String rol; // 🔥 NUEVO

  const InicioUsuario({
    super.key,
    required this.nombreCompleto,
    required this.idUsuario,
    required this.rol, // 🔥
  });

  @override
  State<InicioUsuario> createState() => _InicioUsuarioState();
}

class _InicioUsuarioState extends State<InicioUsuario> {
  int indiceSeleccionado = 0;

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
      backgroundColor: const Color(0xFFE8EEF2),

      /// 🔥 DRAWER CORREGIDO
      drawer: DrawerMenu(
        idUsuario: widget.idUsuario,
        nombreCompleto: widget.nombreCompleto,
        rol: widget.rol,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ICONOS
              Builder(
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 30),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
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

              const SizedBox(height: 10),

              /// SALUDO
              const Text(
                "¡Hola!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                nombreCorto,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// BUSCADOR
              TextField(
                decoration: InputDecoration(
                  hintText: "Buscar",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// REGISTRAR
              widget.rol == "entrenador"
                  ? InkWell(
                      onTap: () {
                        navegarRapido(
                          context,
                          VerEntrenamientosEntrenador(
                            idUsuario: widget.idUsuario,
                            nombreCompleto: widget.nombreCompleto,
                            rol: widget.rol,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A76B8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Image.asset("assets/images/registrar_entrenamiento.png", width: 60), // 🔥 ICONO NUEVO
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ver Entrenamientos",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Consulta tus rutinas",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : InkWell(
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
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A76B8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/registrar_entrenamiento.png",
                              width: 60,
                            ),
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Registrar Entrenamiento",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "¡Registra aquí!",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              /// TARJETAS
              Row(
                children: [
                  /// MIS ENTRENAMIENTOS
                  widget.rol == "entrenador"
                      ? Expanded(
                          child: InkWell(
                            onTap: () {
                              navegarRapido(
                                context,
                                GestionEspacios(
                                  idUsuario: widget.idUsuario,
                                  nombreCompleto: widget.nombreCompleto, rol: widget.rol,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              height: 130,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE84141),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset("assets/images/espacios.png", width: 60), // 🔥 ICONO NUEVO
                                  const Spacer(),
                                  const Text(
                                    "Espacios",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "Añade, modifica o elimina",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: InkWell(
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
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              height: 130,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE84141),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/images/mis_entrenamientos.png",
                                    width: 60,
                                  ),
                                  const Spacer(),
                                  const Text(
                                    "Mis Entrenamientos",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "Ver tus entrenos activos",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(width: 15),

                  /// RESUMEN
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        navegarRapido(
                          context,
                          Resumen(
                            idUsuario: widget.idUsuario,
                            nombreCompleto: widget.nombreCompleto,
                            rol: widget.rol,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 206, 148, 61),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("assets/images/resumen.png", width: 60),
                            const Spacer(),
                            const Text(
                              "Resumen",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Ver tus próximas actividades",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// HISTORIAL
              InkWell(
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/historial.png", width: 60),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Historial",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Mira tu historial deportivo",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔥 BOTTOM NAV CORREGIDO
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceSeleccionado,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            navegarRapido(
              context,
              CalendarioUsuario(
                idUsuario: widget.idUsuario,
                nombreCompleto: widget.nombreCompleto, rol: widget.rol,
              ),
            );
          } else if (index == 2) {
            navegarRapido(
              context,
              RegistrarEntrenamiento(
                idUsuario: widget.idUsuario,
                nombreCompleto: widget.nombreCompleto, rol: widget.rol,
              ),
            );
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
                nombreCompleto: widget.nombreCompleto, rol: widget.rol,
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
