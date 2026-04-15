import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';
import '../widgets/curved_bottom_nav_bar.dart';

class PerfilUsuario extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const PerfilUsuario({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  String nombre = "";
  String documento = "";
  String correo = "";

  Future<void> obtenerDatos() async {
    var url = Uri.parse("https://escuela-deportiva-project.onrender.com/usuario");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": widget.idUsuario}),
      );

      var data = json.decode(response.body);

      if (data["success"] == true) {
        setState(() {
          nombre = data["nombre"];
          documento = data["documento"];
          correo = data["correo"];
        });
      } else {
        setState(() {
          nombre = "No encontrado";
        });
      }
    } catch (e) {
      setState(() {
        nombre = "Error conexión";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerDatos();
  }

  void _mostrarDialogoCambiarContrasena(BuildContext context) {
    final TextEditingController nuevaController = TextEditingController();
    final TextEditingController confirmarController = TextEditingController();

    bool mostrarNueva = false;
    bool mostrarConfirmar = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B2340),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF2E3A5F)),
              ),
              title: const Text(
                "Ingresa tu nueva contraseña",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nuevaController,
                      obscureText: !mostrarNueva,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Contraseña nueva",
                        labelStyle: const TextStyle(color: Color(0xFF7C86A2)),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF7C86A2)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            mostrarNueva ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF7C86A2),
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarNueva = !mostrarNueva;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFF232C4A),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2E3A5F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmarController,
                      obscureText: !mostrarConfirmar,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Confirmar contraseña",
                        labelStyle: const TextStyle(color: Color(0xFF7C86A2)),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF7C86A2)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            mostrarConfirmar ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF7C86A2),
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarConfirmar = !mostrarConfirmar;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFF232C4A),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2E3A5F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                          onPressed: () async {
                            if (nuevaController.text == confirmarController.text &&
                                nuevaController.text.isNotEmpty) {
                              var url = Uri.parse(
                                "https://escuela-deportiva-project.onrender.com/usuario/password",
                              );

                              await http.put(
                                url,
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "id": widget.idUsuario,
                                  "password": nuevaController.text,
                                }),
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Contraseña actualizada"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Las contraseñas no coinciden"),
                                ),
                              );
                            }
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
          },
        );
      },
    );
  }

  void _mostrarDialogoEliminarUsuario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2340),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2E3A5F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "¿Está seguro que quiere eliminar este usuario?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Esta acción no se puede deshacer.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9FA8C3),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      var url = Uri.parse(
                        "https://escuela-deportiva-project.onrender.com/usuarios/${widget.idUsuario}",
                      );

                      var response = await http.delete(url);
                      var data = json.decode(response.body);

                      if (data["success"] == true) {
                        Navigator.pop(context);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrincipalWidget(),
                          ),
                          (route) => false,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Usuario eliminado")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error al eliminar")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
        );
      },
    );
  }

  void _onMenuOptionSelected(BuildContext context, String option) {
    if (option == "Modificar información") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModificarInformacionUsuario(
            idUsuario: widget.idUsuario,
            nombre: nombre,
            documento: documento,
            correo: correo,
          ),
        ),
      ).then((value) {
        if (value == true) {
          obtenerDatos();
        }
      });
    } else if (option == "Cambiar contraseña") {
      _mostrarDialogoCambiarContrasena(context);
    } else if (option == "Eliminar usuario") {
      _mostrarDialogoEliminarUsuario(context);
    }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Builder(
                builder: (context) => Row(
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
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
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          "Mi Perfil",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 44,
                      height: 44,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        color: const Color(0xFF1B2340),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFF2E3A5F)),
                        ),
                        onSelected: (value) =>
                            _onMenuOptionSelected(context, value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: "Modificar información",
                            child: Text(
                              "Modificar información",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          PopupMenuItem(
                            value: "Cambiar contraseña",
                            child: Text(
                              "Cambiar contraseña",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          PopupMenuItem(
                            value: "Eliminar usuario",
                            child: Text(
                              "Eliminar usuario",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2340),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF9FA8C3),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2F80ED).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nombre.isEmpty ? "Cargando..." : nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F80ED).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2F80ED).withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.rol[0].toUpperCase() + widget.rol.substring(1),
                        style: const TextStyle(
                          color: Color(0xFF2F80ED),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F80ED),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Información del usuario",
                            style: TextStyle(
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
                    _infoCard(
                      icono: Icons.person_rounded,
                      label: "Nombre completo",
                      valor: nombre.isEmpty ? "Cargando..." : nombre,
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      icono: Icons.credit_card_rounded,
                      label: "Documento",
                      valor: documento.isEmpty ? "Cargando..." : documento,
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      icono: Icons.email_rounded,
                      label: "Correo electrónico",
                      valor: correo.isEmpty ? "Cargando..." : correo,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) {
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
          } else if (index == 3) {
            navegarRapido(
              context,
              NotificacionesUsuario(
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

  Widget _infoCard({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7C86A2),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
