import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModificarEquipo extends StatefulWidget {
  final int idEquipo;
  final String nombre;
  final String descripcion;
  final int idDeporte;
  final int idEspacio;
  final int idCategoria;
  final int capacidad;
  final int idUsuario;

  const ModificarEquipo({
    super.key,
    required this.idEquipo,
    required this.nombre,
    required this.descripcion,
    required this.idDeporte,
    required this.idEspacio,
    required this.idCategoria,
    required this.capacidad,
    required this.idUsuario,
  });

  @override
  State<ModificarEquipo> createState() => _ModificarEquipoState();
}

class _ModificarEquipoState extends State<ModificarEquipo> {
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

  List<String> diasSeleccionados = [];
  TimeOfDay? horaSeleccionada;

  List<String> dias = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
  ];

  @override
  void initState() {
    super.initState();

    nombreController.text = widget.nombre;
    descripcionController.text = widget.descripcion;
    capacidadController.text = widget.capacidad.toString();

    deporteSeleccionado = widget.idDeporte;
    espacioSeleccionado = widget.idEspacio;
    categoriaSeleccionada = widget.idCategoria;

    obtenerDeportes();
    obtenerCategorias();
    obtenerEspacios(widget.idDeporte);
    cargarHorario();
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    capacidadController.dispose();
    super.dispose();
  }

  /// =========================
  /// 🔥 CARGAR HORARIO
  /// =========================
  Future<void> cargarHorario() async {
    try {
      var res = await http.get(
        Uri.parse("$baseUrl/equipos/${widget.idEquipo}/horario"),
      );

      var data = json.decode(res.body);

      if (data["success"]) {
        setState(() {
          diasSeleccionados = List<String>.from(data["dias"] ?? []);

          if (data["hora"] != null) {
            final parts = data["hora"].split(":");
            horaSeleccionada = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        });
      }
    } catch (e) {
      print("ERROR HORARIO: $e");
    }
  }

  /// =========================
  /// 🔥 DEPORTES
  /// =========================
  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$baseUrl/deportes"));
    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        deportes = data["deportes"];
      });
    }
  }

  /// =========================
  /// 🔥 ESPACIOS
  /// =========================
  Future<void> obtenerEspacios(int idDeporte) async {
    var res = await http.get(
      Uri.parse(
        "$baseUrl/espacios/deporte-entrenador/$idDeporte/${widget.idUsuario}",
      ),
    );

    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        espacios = List<Map<String, dynamic>>.from(data["data"]);
      });
    }
  }

  /// =========================
  /// 🔥 CATEGORIAS
  /// =========================
  Future<void> obtenerCategorias() async {
    var res = await http.get(Uri.parse("$baseUrl/categorias"));
    var data = json.decode(res.body);

    if (data["success"]) {
      setState(() {
        categorias = data["categorias"];
      });
    }
  }

  /// =========================
  /// 🔥 MODIFICAR EQUIPO
  /// =========================
  Future<void> modificarEquipo() async {
    try {
      var res = await http.put(
        Uri.parse(
          "$baseUrl/equipos/${widget.idEquipo}?id_usuario=${widget.idUsuario}",
        ),
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
          "hora": horaSeleccionada != null
              ? "${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}"
              : null,
        }),
      );

      var data = json.decode(res.body);

      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Equipo modificado correctamente")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["error"] ?? "Error")));
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
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF1B2340),
              hourMinuteColor: Color(0xFF232C4A),
              hourMinuteTextColor: Colors.white,
              dayPeriodColor: Color(0xFF232C4A),
              dayPeriodTextColor: Colors.white,
              dialBackgroundColor: Color(0xFF232C4A),
              dialHandColor: Color(0xFF2F80ED),
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.white,
              helpTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              hourMinuteTextStyle: TextStyle(
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
                "Modificar equipo",
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
                        Icons.sports_soccer_rounded,
                        "Seleccionar deporte",
                        deporteSeleccionado,
                        deportes,
                        (value) {
                          setState(() {
                            deporteSeleccionado = value;
                            espacioSeleccionado = null;
                            espacios = [];
                          });

                          if (value != null) {
                            obtenerEspacios(value);
                          }
                        },
                        "id_deporte",
                        "nombre",
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        Icons.category_outlined,
                        "Seleccionar categoría",
                        categoriaSeleccionada,
                        categorias,
                        (value) {
                          setState(() {
                            categoriaSeleccionada = value;
                          });
                        },
                        "id_categoria",
                        "nombre",
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        Icons.location_on_outlined,
                        "Seleccionar espacio",
                        espacioSeleccionado,
                        espacios,
                        (value) {
                          setState(() {
                            espacioSeleccionado = value;
                          });
                        },
                        "id_espacio",
                        "nombre",
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
                                final seleccionado =
                                    diasSeleccionados.contains(dia);

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
                                                color: const Color(0xFF1E5DBF)
                                                    .withOpacity(0.35),
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
                            onPressed: modificarEquipo,
                            child: const Text(
                              "Modificar",
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
          borderSide: const BorderSide(
            color: Color(0xFF2F80ED),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    IconData icon,
    String hint,
    int? value,
    List items,
    Function(int?) onChanged,
    String idKey,
    String textKey,
  ) {
    return DropdownButtonFormField<int>(
      value: items.any((e) => e[idKey] == value) ? value : null,
      dropdownColor: const Color(0xFF1B2340),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
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
          borderSide: const BorderSide(
            color: Color(0xFF2F80ED),
            width: 2,
          ),
        ),
      ),
      hint: Text(
        hint,
        style: const TextStyle(
          color: Color(0xFF7C86A2),
          fontSize: 15,
        ),
      ),
      selectedItemBuilder: (context) {
        return items.map<Widget>((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item[textKey],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFF7C86A2),
      ),
    );
  }
}
