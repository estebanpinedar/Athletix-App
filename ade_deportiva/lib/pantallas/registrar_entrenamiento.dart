import 'package:flutter/material.dart';

class RegistrarEntrenamiento extends StatefulWidget {
  const RegistrarEntrenamiento({super.key, required int idUsuario, required String nombreCompleto});

  @override
  State<RegistrarEntrenamiento> createState() => _RegistrarEntrenamientoState();
}

class _RegistrarEntrenamientoState extends State<RegistrarEntrenamiento> {
  String? deporteSeleccionado;
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  final List<String> deportes = [
    "Atletismo",
    "Baloncesto",
    "Fútbol",
    "Natación",
    "Voleibol",
  ];

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        horaSeleccionada = picked;
      });
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
              /// LOGO
              Center(child: Image.asset("assets/images/logo.png", height: 160)),
              const SizedBox(height: 10),

              /// TÍTULO
              const Text(
                "Nuevo Entrenamiento",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              /// CAMPO DEPORTE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_soccer, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: "Seleccionar deporte",
                        ),
                        value: deporteSeleccionado,
                        items: deportes
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            deporteSeleccionado = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// CAMPO FECHA
              GestureDetector(
                onTap: () => _seleccionarFecha(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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

              /// CAMPO HORA
              GestureDetector(
                onTap: () => _seleccionarHora(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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

              /// BOTÓN CONFIRMAR (grande, negro)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Entrenamiento confirmado")),
                    );
                  },
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              /// BOTÓN CANCELAR (más pequeño, casi blanco con contorno)
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // vuelve a la ventana anterior
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
      ),
    );
  }
}