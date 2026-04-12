import 'package:flutter/material.dart';

class GestionEspacios extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String rol;

  const GestionEspacios({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.rol,
  });

  @override
  State<GestionEspacios> createState() => _GestionEspaciosState();
}

class _GestionEspaciosState extends State<GestionEspacios> {

  List espacios = [];

  @override
  void initState() {
    super.initState();
    // 🔥 AQUÍ LUEGO LLAMAS TU API
    // obtenerEspacios();
  }

  void crearEspacio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Crear espacio")),
    );
  }

  void editarEspacio(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Editar espacio ${espacios[index]["nombre"]}")),
    );
  }

  void eliminarEspacio(int index) {
    setState(() {
      espacios.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Espacio eliminado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),

      appBar: AppBar(
        title: const Text("Gestión de Espacios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: crearEspacio,
          ),
        ],
      ),

      body: espacios.isEmpty
          ? const Center(
              child: Text("No hay espacios registrados"),
            )
          : ListView.builder(
              itemCount: espacios.length,
              itemBuilder: (context, index) {
                var e = espacios[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/espacios.png",
                      width: 40,
                    ),
                    title: Text(e["nombre"] ?? "Espacio"),
                    subtitle: Text(e["descripcion"] ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editarEspacio(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarEspacio(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}