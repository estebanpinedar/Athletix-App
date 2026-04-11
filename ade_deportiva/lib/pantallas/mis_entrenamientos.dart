import 'package:flutter/material.dart';
import 'animaciones.dart';
import 'modificar_entrenamiento.dart';

class MisEntrenamientos extends StatefulWidget {
  const MisEntrenamientos({super.key, required int idUsuario});

  @override
  State<MisEntrenamientos> createState() => _MisEntrenamientosState();
}

class _MisEntrenamientosState extends State<MisEntrenamientos> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> entrenamientos = [
    {"titulo": "Fútbol - Infantil", "fecha": "12/11/2025", "hora": "15:00"},
    {"titulo": "Atletismo - Juvenil", "fecha": "13/11/2025", "hora": "09:00"},
  ];

  void _mostrarDialogoEliminar(Map<String, String> entrenamiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TEXTO MÁS GRANDE Y CENTRADO
            const Text(
              "¿Está seguro que quiere eliminar este entrenamiento?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, // más grande
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            /// BOTÓN CONFIRMAR (negro, más pequeño)
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
                onPressed: () {
                  Navigator.pop(context); // cerrar diálogo
                  setState(() {
                    entrenamientos.remove(entrenamiento); // elimina de la lista
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Entrenamiento eliminado: ${entrenamiento["titulo"]}",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// BOTÓN CANCELAR (gris claro con contorno, centrado)
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
                  Navigator.pop(context); // cerrar diálogo
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
  }

  void _onMenuOptionSelected(String option, Map<String, String> entrenamiento) {
    if (option == "Modificar") {
      // Abre la ventana de modificar entrenamiento
      navegarRapido(context, const ModificarEntrenamiento());
    } else if (option == "Eliminar") {
      _mostrarDialogoEliminar(entrenamiento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      body: SafeArea(
        child: Column(
          children: [
            /// FLECHA DE REGRESO
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            /// TÍTULO CENTRADO Y GRANDE
            const Text(
              "Mis Entrenamientos",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// BUSCADOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// LISTA DE ENTRENAMIENTOS
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entrenamientos.length,
                itemBuilder: (context, index) {
                  final entrenamiento = entrenamientos[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// ÍCONO DE PERSONA ENTRENANDO
                        const Icon(
                          Icons.directions_run,
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),

                        /// INFORMACIÓN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entrenamiento["titulo"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${entrenamiento["fecha"]} - ${entrenamiento["hora"]}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// MENÚ OPCIONES
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) =>
                              _onMenuOptionSelected(value, entrenamiento),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "Modificar",
                              child: Text("Modificar"),
                            ),
                            const PopupMenuItem(
                              value: "Eliminar",
                              child: Text("Eliminar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
