import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens.dart';

class RegistroUsuario extends StatefulWidget {
  const RegistroUsuario({super.key});

  @override
  State<RegistroUsuario> createState() => _RegistroUsuarioState();
}

class _RegistroUsuarioState extends State<RegistroUsuario> {
  String? rolSeleccionado;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? errorPassword;
  String? errorConfirmPassword;

  // CONTROLADORES
  final nombreController = TextEditingController();
  final documentoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// 🔥 REGISTRO
  Future<void> registrar() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorConfirmPassword = "Las contraseñas no coinciden";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (errorPassword != null || errorConfirmPassword != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Corrige los errores antes de continuar")),
      );
      return;
    }

    if (rolSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona un rol")));
      return;
    }

    var url = Uri.parse(
      "https://escuela-deportiva-project.onrender.com/usuarios",
    );

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombreController.text.trim(),
          "documento": documentoController.text.trim(),
          "email": correoController.text.trim(),
          "password": passwordController.text.trim(),
          "rol": rolSeleccionado,
        }),
      );

      var data = json.decode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario registrado correctamente")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IniciarSesion()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Error al registrar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  Widget _input(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirm ? obscureConfirmPassword : obscurePassword)
          : false,
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() {
          if (isPassword && !isConfirm) {
            errorPassword = value.length < 6 ? "Mínimo 6 caracteres" : null;
          }

          if (isConfirm) {
            errorConfirmPassword = value != passwordController.text
                ? "Las contraseñas no coinciden"
                : null;
          }
        });
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF7C86A2)),

        /// 👁️ ICONO FUNCIONAL
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isConfirm
                      ? (obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility)
                      : (obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                  color: const Color(0xFF7C86A2),
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    } else {
                      obscurePassword = !obscurePassword;
                    }
                  });
                },
              )
            : null,

        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
        filled: true,
        fillColor: const Color(0xFF232C4A),

        /// 🔴 BORDE DINÁMICO
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                (isConfirm && errorConfirmPassword != null) ||
                    (!isConfirm && errorPassword != null && isPassword)
                ? Colors.red
                : const Color(0xFF2E3A5F),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                (isConfirm && errorConfirmPassword != null) ||
                    (!isConfirm && errorPassword != null && isPassword)
                ? Colors.red
                : const Color(0xFF2F80ED),
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),

        /// ❗ ERROR
        errorText: isConfirm
            ? errorConfirmPassword
            : (isPassword ? errorPassword : null),
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    documentoController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔙 BOTÓN ATRÁS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2340),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF9FA8C3),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CONTENIDO
            Expanded(
              child: Stack(
                children: [
                  /// CENTRO
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          /// CARD
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2340),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                /// ICONO
                                Center(
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2F80ED),
                                          Color(0xFF1E5DBF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                const Text(
                                  "Crear cuenta",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  "Regístrate en el sistema deportivo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF9FA8C3)),
                                ),

                                const SizedBox(height: 30),

                                /// NOMBRE
                                _input(
                                  nombreController,
                                  Icons.person,
                                  "Nombre completo",
                                ),

                                const SizedBox(height: 15),

                                /// DOCUMENTO
                                _input(
                                  documentoController,
                                  Icons.badge,
                                  "Número de identificación",
                                ),

                                const SizedBox(height: 15),

                                /// EMAIL
                                _input(
                                  correoController,
                                  Icons.email,
                                  "Correo electrónico",
                                ),

                                const SizedBox(height: 15),

                                /// PASSWORD
                                _input(
                                  passwordController,
                                  Icons.lock,
                                  "Contraseña",
                                  isPassword: true,
                                ),

                                const SizedBox(height: 15),

                                /// CONFIRM PASSWORD
                                _input(
                                  confirmPasswordController,
                                  Icons.lock,
                                  "Confirmar contraseña",
                                  isPassword: true,
                                ),

                                const SizedBox(height: 15),

                                /// ROL
                                DropdownButtonFormField<String>(
                                  value: rolSeleccionado,
                                  dropdownColor: const Color(0xFF232C4A),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.group,
                                      color: Color(0xFF7C86A2),
                                    ),

                                    hint: Transform.translate(
                                      offset: const Offset(0, -8),
                                      child: const Text(
                                        "Selecciona tu rol",
                                        style: TextStyle(
                                          color: Color(0xFF7C86A2),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    filled: true,
                                    fillColor: const Color(0xFF232C4A),

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
                                      ),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "alumno",
                                      child: Text("Alumno"),
                                    ),
                                    DropdownMenuItem(
                                      value: "entrenador",
                                      child: Text("Entrenador"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      rolSeleccionado = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 25),

                                /// BOTÓN REGISTRAR
                                SizedBox(
                                  height: 55,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2F80ED),
                                          Color(0xFF1E5DBF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: registrar,
                                      child: const Text(
                                        "Registrar",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// LOGIN
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "¿Ya tienes cuenta? ",
                                      style: TextStyle(
                                        color: Color(0xFF9FA8C3),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        navegarRapido(
                                          context,
                                          const IniciarSesion(),
                                        );
                                      },
                                      child: const Text(
                                        "Inicia sesión",
                                        style: TextStyle(
                                          color: Color(0xFF2F80ED),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  /// FOOTER
                  const Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Plataforma segura de gestión deportiva",
                        style: TextStyle(
                          color: Color(0xFF7C86A2),
                          fontSize: 12,
                        ),
                      ),
                    ),
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
