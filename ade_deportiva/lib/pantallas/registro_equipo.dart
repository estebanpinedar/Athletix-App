import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroEquipo extends StatefulWidget {
  final int idUsuario;

  const RegistroEquipo({super.key, required this.idUsuario});

  @override
  State<RegistroEquipo> createState() => _RegistroEquipoState();
}

class _RegistroEquipoState extends State<RegistroEquipo> {
  List<String> dias = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
  ];

  List<String> diasSeleccionados = [];

  TimeOfDay? horaSeleccionada;
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final capacidadController = TextEditingController();

  final String baseUrl = "https://escuela-deportiva-project.onrender.com";

  List deportes = [];
  List espacios = [];
  List categorias = [];

  int? deporteSeleccionado;
  int? espacioSeleccionado;
  int? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    obtenerDeportes();
    obtenerCategorias();
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    capacidadController.dispose();
    super.dispose();
  }

  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$baseUrl/deportes"));
    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        deportes = data["deportes"];
      });
    }
  }

  Future<void> obtenerEspacios(int idDeporte) async {
    try {
      var res = await http.get(
        Uri.parse(
          "$baseUrl/espacios/deporte-entrenador/$idDeporte/${widget.idUsuario}",
        ),
      );

      var data = json.decode(res.body);

      print("ESPACIOS => $data");

      if (data["success"]) {
        setState(() {
          espacios = data["data"];
        });
      }
    } catch (e) {
      print("Error espacios: $e");
    }
  }

  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$baseUrl/categorias"));
    var data = json.decode(res.body);

    print("CATEGORIAS => $data");

    if (data["success"]) {
      setState(() {
        categorias = data["categorias"];
      });
    }
  }

  Future<void> registrarEquipo() async {
    if (nombreController.text.isEmpty ||
        deporteSeleccionado == null ||
        espacioSeleccionado == null ||
        categoriaSeleccionada == null ||
        capacidadController.text.isEmpty ||
        diasSeleccionados.isEmpty ||
        horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    try {
      var res = await http.post(
        Uri.parse("$baseUrl/equipos"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombreController.text,
          "descripcion": descripcionController.text,
          "id_deporte": deporteSeleccionado,
          "id_espacio": espacioSeleccionado,
          "id_categoria": categoriaSeleccionada,
          "capacidad_maxima": int.parse(capacidadController.text),
          "id_usuario": widget.idUsuario,
          "dias": diasSeleccionados,
          "hora": horaSeleccionada!.format(context),
        }),
      );

      var data = json.decode(res.body);

      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Equipo registrado correctamente")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Error al registrar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void toggleDia(String dia) {
    setState(() {
      if (diasSeleccionados.contains(dia)) {
        diasSeleccionados.remove(dia);
      } else {
        diasSeleccionados.add(dia);
      }
    });
  }

  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horaSeleccionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2F80ED),
              onPrimary: Colors.white,
              surface: Color(0xFF1B2340),
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFF1B2340),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1B2340),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF1B2340),
              hourMinuteColor: const Color(0xFF232C4A),
              hourMinuteTextColor: Colors.white,
              dayPeriodColor: const Color(0xFF232C4A),
              dayPeriodTextColor: Colors.white,
              dialBackgroundColor: const Color(0xFF232C4A),
              dialHandColor: const Color(0xFF2F80ED),
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.white,
              helpTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              hourMinuteTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        horaSeleccionada = hora;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF12192D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2340),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E3A5F)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF9FA8C3),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Registro de equipo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _input(
                        Icons.groups_rounded,
                        "Nombre del equipo",
                        nombreController,
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        icon: Icons.sports_soccer_rounded,
                        label: "Seleccionar deporte",
                        value: deporteSeleccionado,
                        items: deportes,
                        onChanged: (value) {
                          setState(() {
                            deporteSeleccionado = value;
                            categoriaSeleccionada = null;
                            espacioSeleccionado = null;
                            espacios = [];
                          });

                          if (value != null) {
                            obtenerEspacios(value);
                          }
                        },
                        idKey: "id_deporte",
                        textKey: "nombre",
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        icon: Icons.category_outlined,
                        label: "Seleccionar categoría",
                        value: categoriaSeleccionada,
                        items: categorias,
                        onChanged: (value) {
                          setState(() {
                            categoriaSeleccionada = value;
                          });
                        },
                        idKey: "id_categoria",
                        textKey: "nombre",
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        icon: Icons.location_on_outlined,
                        label: "Seleccionar espacio",
                        value: espacioSeleccionado,
                        items: espacios,
                        onChanged: (value) {
                          setState(() {
                            espacioSeleccionado = value;
                          });
                        },
                        idKey: "id_espacio",
                        textKey: "nombre",
                      ),
                      const SizedBox(height: 16),
                      _input(
                        Icons.people_alt_outlined,
                        "Capacidad máxima",
                        capacidadController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 16),
                      _input(
                        Icons.description_outlined,
                        "Descripción",
                        descripcionController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2340),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF2E3A5F)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color(0xFF2F80ED),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Días de entrenamiento",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Selecciona uno o varios días",
                              style: TextStyle(
                                color: Color(0xFF7C86A2),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: dias.map((dia) {
                                final seleccionado = diasSeleccionados.contains(
                                  dia,
                                );

                                return GestureDetector(
                                  onTap: () => toggleDia(dia),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: seleccionado
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF2F80ED),
                                                Color(0xFF1E5DBF),
                                              ],
                                            )
                                          : null,
                                      color: seleccionado
                                          ? null
                                          : const Color(0xFF232C4A),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: seleccionado
                                            ? const Color(0xFF2F80ED)
                                            : const Color(0xFF2E3A5F),
                                      ),
                                      boxShadow: seleccionado
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF1E5DBF,
                                                ).withOpacity(0.35),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          seleccionado
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          dia,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _selectorHora(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E5DBF).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: registrarEquipo,
                            child: const Text(
                              "Registrar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2E3A5F)),
                            backgroundColor: const Color(0xFF232C4A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(
                              color: Color(0xFF9FA8C3),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectorHora() {
    final bool tieneHora = horaSeleccionada != null;

    return GestureDetector(
      onTap: seleccionarHora,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2340),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tieneHora
                ? const Color(0xFF2F80ED)
                : const Color(0xFF2E3A5F),
            width: tieneHora ? 1.5 : 1,
          ),
          boxShadow: tieneHora
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E5DBF).withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2F80ED), Color(0xFF1E5DBF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hora de entrenamiento",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tieneHora
                        ? horaSeleccionada!.format(context)
                        : "Seleccionar hora",
                    style: TextStyle(
                      color: tieneHora
                          ? const Color(0xFFBFD8FF)
                          : const Color(0xFF7C86A2),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF7C86A2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    IconData icon,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 36 : 0),
          child: Icon(icon, color: const Color(0xFF7C86A2)),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7C86A2)),
        filled: true,
        fillColor: const Color(0xFF1B2340),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
        ),
      ),
    );
  }

  Widget _dropdown({
    required IconData icon,
    required String label,
    required int? value,
    required List items,
    required Function(int?) onChanged,
    required String idKey,
    required String textKey,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: const Color(0xFF1B2340),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF7C86A2)),
        filled: true,
        fillColor: const Color(0xFF1B2340),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
        ),
      ),
      hint: Text(
        label,
        style: const TextStyle(color: Color(0xFF7C86A2), fontSize: 15),
      ),
      selectedItemBuilder: (context) {
        return items.map<Widget>((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item[textKey],
              style: const TextStyle(color: Colors.white, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      items: items.map<DropdownMenuItem<int>>((item) {
        return DropdownMenuItem<int>(
          value: item[idKey],
          child: Text(
            item[textKey],
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7C86A2)),
    );
  }
}
