import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrarEntrenamiento extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const RegistrarEntrenamiento({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<RegistrarEntrenamiento> createState() => _RegistrarEntrenamientoState();
}

class _RegistrarEntrenamientoState extends State<RegistrarEntrenamiento> {
  int? idDeporte;
  int? idEspacio;

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  List deportes = [];
  List espacios = [];

  final String api =
      "https://escuela-deportiva-project.onrender.com"; // 🔥 CAMBIA

  @override
  void initState() {
    super.initState();
    obtenerDeportes();
  }

  /// 🔥 OBTENER DEPORTES
  Future<void> obtenerDeportes() async {
    var res = await http.get(Uri.parse("$api/deportes"));
    var data = json.decode(res.body);

    setState(() {
      deportes = data;
    });
  }

  /// 🔥 OBTENER ESPACIOS POR DEPORTE
  Future<void> obtenerEspacios(int idDep) async {
    var res = await http.get(Uri.parse("$api/espacios/deporte/$idDep"));
    var data = json.decode(res.body);

    setState(() {
      espacios = data;
    });
  }

  /// 🔥 GUARDAR ENTRENAMIENTO
  Future<void> guardar() async {
    if (idDeporte == null ||
        idEspacio == null ||
        fechaSeleccionada == null ||
        horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    var res = await http.post(
      Uri.parse("$api/entrenamientos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_deporte": idDeporte,
        "id_espacio": idEspacio,
        "id_entrenador": widget.idUsuario,
        "fecha": fechaSeleccionada.toString().split(" ")[0],
        "hora":
            "${horaSeleccionada!.hour}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}",
      }),
    );

    var data = json.decode(res.body);

    if (data["success"]) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Entrenamiento registrado")));
      Navigator.pop(context);
    }
  }

  /// 🎨 FECHA BONITA
  String formatoFecha() {
    if (fechaSeleccionada == null) return "Seleccionar fecha";
    return "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}";
  }

  /// 🎨 HORA BONITA
  String formatoHora() {
    if (horaSeleccionada == null) return "Seleccionar hora";
    return "${horaSeleccionada!.hour}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}";
  }

  Future<void> seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => fechaSeleccionada = picked);
    }
  }

  Future<void> seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => horaSeleccionada = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png", height: 140),

              const SizedBox(height: 10),

              const Text(
                "Nuevo Entrenamiento",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              /// 🔥 DEPORTE
              DropdownButtonFormField<int>(
                value: idDeporte,
                hint: const Text("Seleccionar deporte"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(
                    Icons.sports_soccer,
                    color: Colors.blue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: deportes.map<DropdownMenuItem<int>>((d) {
                  return DropdownMenuItem<int>(
                    value: int.parse(d["id_deporte"].toString()), // 🔥 FIX
                    child: Text(d["nombre"]),
                  );
                }).toList(),
                onChanged: (value) {
                  print("Seleccionado: $value"); // 🔥 DEBUG

                  setState(() {
                    idDeporte = value;
                    idEspacio = null;
                    espacios = [];
                  });

                  if (value != null) {
                    obtenerEspacios(value);
                  }
                },
              ),

              const SizedBox(height: 20),

              /// 🔥 ESPACIO (DINÁMICO)
              if (idDeporte != null)
                DropdownButtonFormField<int>(
                  value: idEspacio,
                  hint: const Text("Seleccionar espacio"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: espacios.map<DropdownMenuItem<int>>((e) {
                    return DropdownMenuItem(
                      value: e["id_espacio"],
                      child: Text("${e["nombre"]} - ${e["entrenador"]}"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      idEspacio = value;
                    });
                  },
                ),

              const SizedBox(height: 20),

              /// 🔥 FECHA (MEJORADA)
              GestureDetector(
                onTap: seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fechaSeleccionada == null
                              ? "Seleccionar fecha"
                              : "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 HORA (MEJORADA)
              GestureDetector(
                onTap: seleccionarHora,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          horaSeleccionada == null
                              ? "Seleccionar hora"
                              : "${horaSeleccionada!.hour}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 BOTÓN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: guardar,
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
