import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';

class PerfilUsuario extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;

  const PerfilUsuario({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
  });

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  String nombre = "";
  String documento = "";
  String correo = "";

  /// 🔥 OBTENER DATOS REALES
  Future<void> obtenerDatos() async {
    var url = Uri.parse("https://escuela-api.onrender.com/usuario");

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

  /// 🔐 CAMBIAR CONTRASEÑA (visual)
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Ingresa tu nueva contraseña",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// CONTRASEÑA NUEVA
                    TextField(
                      controller: nuevaController,
                      obscureText: !mostrarNueva,
                      decoration: InputDecoration(
                        labelText: "Contraseña nueva",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            mostrarNueva
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarNueva = !mostrarNueva;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// CONFIRMAR CONTRASEÑA
                    TextField(
                      controller: confirmarController,
                      obscureText: !mostrarConfirmar,
                      decoration: InputDecoration(
                        labelText: "Confirmar contraseña",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            mostrarConfirmar
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarConfirmar = !mostrarConfirmar;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                        onPressed: () async {
                          if (nuevaController.text ==
                                  confirmarController.text &&
                              nuevaController.text.isNotEmpty) {
                            var url = Uri.parse(
                              "https://escuela-api.onrender.com/usuario/password",
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
          },
        );
      },
    );
  }

  /// ❌ ELIMINAR USUARIO (visual)
  void _mostrarDialogoEliminarUsuario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TEXTO
              const Text(
                "¿Está seguro que quiere eliminar este usuario?",
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
                  onPressed: () async {
                    try {
                      var url = Uri.parse(
                        "https://escuela-api.onrender.com/usuarios/${widget.idUsuario}",
                      );

                      var response = await http.delete(url);
                      var data = json.decode(response.body);

                      if (data["success"] == true) {
                        // 🔥 cerrar diálogo
                        Navigator.pop(context);

                        // 🔥 ir a pantalla principal y limpiar historial
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
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
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
        );
      },
    );
  }

  /// 🔧 MENÚ OPCIONES
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
          obtenerDatos(); // 🔥 refresca datos
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
      backgroundColor: const Color(0xFFE8EEF2),
      drawer: DrawerMenu(idUsuario: widget.idUsuario),

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

                    /// OPCIONES
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) =>
                          _onMenuOptionSelected(context, value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "Modificar información",
                          child: Text("Modificar información"),
                        ),
                        PopupMenuItem(
                          value: "Cambiar contraseña",
                          child: Text("Cambiar contraseña"),
                        ),
                        PopupMenuItem(
                          value: "Eliminar usuario",
                          child: Text("Eliminar usuario"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// FOTO PERFIL
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            /// TITULO
            const Text(
              "Información del usuario",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// DATOS REALES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  /// NOMBRE
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(nombre.isEmpty ? "Cargando..." : nombre),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DOCUMENTO
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.credit_card,
                        color: Colors.blue,
                      ),
                      title: Text(
                        documento.isEmpty ? "Cargando..." : documento,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// CORREO
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(correo.isEmpty ? "Cargando..." : correo),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      /// 🔻 BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
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
              ),
            );
          } else if (index == 1) {
            navegarRapido(
              context,
              CalendarioUsuario(
                idUsuario: widget.idUsuario,
                nombreCompleto: widget.nombreCompleto,
              ),
            );
          } else if (index == 2) {
            navegarRapido(
              context,
              RegistrarEntrenamiento(idUsuario: widget.idUsuario),
            );
          } else if (index == 3) {
            navegarRapido(
              context,
              NotificacionesUsuario(
                idUsuario: widget.idUsuario,
                nombreCompleto: '',
              ),
            );
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
