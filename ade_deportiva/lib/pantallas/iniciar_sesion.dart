import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'screens.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  static const String _baseUrl =
      'https://escuela-deportiva-project.onrender.com';

  bool obscurePassword = true;
  bool isLoggingIn = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    if (isLoggingIn) return;

    setState(() {
      isLoggingIn = true;
    });

    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['success'] == true) {
        final int id = int.parse(data['id'].toString());
        final String nombre = data['nombre'].toString();
        final String rol = data['rol'].toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicioUsuario(
              nombreCompleto: nombre,
              idUsuario: id,
              rol: rol,
            ),
          ),
        );
      } else {
        _mostrarMensaje(data['msg']?.toString() ?? 'No se pudo iniciar sesión');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoggingIn = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final responseBody = response.body.trimLeft();
    final contentType = response.headers['content-type'] ?? '';

    if (responseBody.startsWith('<!DOCTYPE html') ||
        responseBody.startsWith('<html') ||
        contentType.contains('text/html')) {
      throw Exception(
        'El servidor devolvió HTML en lugar de JSON. Debes actualizar/publicar el backend con los endpoints de recuperación de contraseña.',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _solicitarRecuperacion(String email) async {
    final data = await _postJson('password-reset/request', {'email': email});

    if (data['success'] != true) {
      throw Exception(data['msg'] ?? 'No se pudo enviar el código');
    }
  }

  Future<void> _verificarCodigo(String email, String code) async {
    final data = await _postJson('password-reset/verify', {
      'email': email,
      'code': code,
    });

    if (data['success'] != true) {
      throw Exception(data['msg'] ?? 'El código no es válido');
    }
  }

  Future<void> _confirmarNuevaContrasena(
    String email,
    String code,
    String password,
  ) async {
    final data = await _postJson('password-reset/confirm', {
      'email': email,
      'code': code,
      'password': password,
    });

    if (data['success'] != true) {
      throw Exception(data['msg'] ?? 'No se pudo actualizar la contraseña');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF7C86A2)),
      suffixIcon: suffixIcon,
      hintText: hintText,
      counterText: counterText,
      hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
      filled: true,
      fillColor: const Color(0xFF232C4A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2E3A5F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
      ),
    );
  }

  BoxDecoration _dialogDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1B2340),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ],
    );
  }

  Widget _buildDialogIcon(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required Future<void> Function() onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoRecuperarContrasena(BuildContext context) {
    final recoveryEmailController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _dialogDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogIcon(Icons.lock_reset),
              const SizedBox(height: 20),
              const Text(
                'Recuperar contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ingresa tu correo electrónico para validar si está registrado y enviarte un código.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9FA8C3), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: recoveryEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hintText: 'Correo electrónico',
                  icon: Icons.email,
                ),
              ),
              const SizedBox(height: 25),
              _buildPrimaryButton(
                label: 'Enviar código',
                onPressed: () async {
                  final email =
                      recoveryEmailController.text.trim().toLowerCase();

                  if (email.isEmpty) {
                    _mostrarMensaje('Debes ingresar un correo');
                    return;
                  }

                  try {
                    await _solicitarRecuperacion(email);
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _mostrarMensaje(
                      'Se envió un código de verificación al correo',
                    );
                    _mostrarDialogoCodigoRecuperacion(context, email);
                  } catch (e) {
                    _mostrarMensaje(
                      e.toString().replaceFirst('Exception: ', ''),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF7C86A2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoCodigoRecuperacion(BuildContext context, String email) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _dialogDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogIcon(Icons.verified_user),
              const SizedBox(height: 20),
              const Text(
                'Ingresar código',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Escribe el código de 6 dígitos enviado a $email',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9FA8C3), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hintText: 'Código de 6 dígitos',
                  icon: Icons.pin_outlined,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 25),
              _buildPrimaryButton(
                label: 'Verificar código',
                onPressed: () async {
                  final code = codeController.text.trim();

                  if (code.length != 6) {
                    _mostrarMensaje('El código debe tener 6 dígitos');
                    return;
                  }

                  try {
                    await _verificarCodigo(email, code);
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _mostrarDialogoNuevaContrasena(context, email, code);
                  } catch (e) {
                    _mostrarMensaje(
                      e.toString().replaceFirst('Exception: ', ''),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF7C86A2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoNuevaContrasena(
    BuildContext context,
    String email,
    String code,
  ) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool ocultarNueva = true;
    bool ocultarConfirmacion = true;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogIcon(Icons.lock_open),
                const SizedBox(height: 20),
                const Text(
                  'Nueva contraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingresa y confirma la nueva contraseña para actualizarla.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9FA8C3), fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: newPasswordController,
                  obscureText: ocultarNueva,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    hintText: 'Nueva contraseña',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarNueva ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF7C86A2),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          ocultarNueva = !ocultarNueva;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: ocultarConfirmacion,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    hintText: 'Confirmar contraseña',
                    icon: Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarConfirmacion
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF7C86A2),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          ocultarConfirmacion = !ocultarConfirmacion;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildPrimaryButton(
                  label: 'Cambiar contraseña',
                  onPressed: () async {
                    final nueva = newPasswordController.text.trim();
                    final confirmacion = confirmPasswordController.text.trim();

                    if (nueva.isEmpty || confirmacion.isEmpty) {
                      _mostrarMensaje(
                        'Debes completar ambos campos de contraseña',
                      );
                      return;
                    }

                    if (nueva != confirmacion) {
                      _mostrarMensaje('Las contraseñas no coinciden');
                      return;
                    }

                    try {
                      await _confirmarNuevaContrasena(email, code, nueva);
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      _mostrarMensaje(
                        'La contraseña fue actualizada correctamente',
                      );
                    } catch (e) {
                      _mostrarMensaje(
                        e.toString().replaceFirst('Exception: ', ''),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF7C86A2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
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
                                  Icons.login,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              'Bienvenido',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sistema Gestor de Escuelas Deportivas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9FA8C3),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'CORREO ELECTRÓNICO',
                              style: TextStyle(
                                color: Color(0xFF7C86A2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                hintText: 'tu@email.com',
                                icon: Icons.email,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'CONTRASEÑA',
                              style: TextStyle(
                                color: Color(0xFF7C86A2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                hintText: '••••••••',
                                icon: Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF7C86A2),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: isLoggingIn
                                      ? null
                                      : () => login(context),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isLoggingIn
                                        ? const Row(
                                            key: ValueKey('loading'),
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Cargando...',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'Iniciar Sesión',
                                            key: ValueKey('label'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  _mostrarDialogoRecuperarContrasena(context);
                                },
                                child: const Text(
                                  'Recuperar contraseña',
                                  style: TextStyle(color: Color(0xFF2F80ED)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Color(0xFF2E3A5F)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'O',
                                    style: TextStyle(
                                      color: Color(0xFF7C86A2),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Color(0xFF2E3A5F)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿No tienes cuenta? ',
                                  style: TextStyle(color: Color(0xFF9FA8C3)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    navegarRapido(
                                      context,
                                      const RegistroUsuario(),
                                    );
                                  },
                                  child: const Text(
                                    'Crear una',
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
            ),
          ],
        ),
      ),
    );
  }
}
