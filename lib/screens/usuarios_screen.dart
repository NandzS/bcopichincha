import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final nombreCtrl = TextEditingController();
  final saldoCtrl = TextEditingController();
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final data = await DatabaseHelper.instance.getUsuarios();
    setState(() {
      usuarios = data;
    });
  }

  Future<void> agregarUsuario() async {
    if (nombreCtrl.text.isEmpty || saldoCtrl.text.isEmpty) return;
    await DatabaseHelper.instance.insertUsuario({
      'nombre': nombreCtrl.text,
      'saldo': double.tryParse(saldoCtrl.text) ?? 0.0,
    });
    nombreCtrl.clear();
    saldoCtrl.clear();
    cargarUsuarios();
  }

  Future<void> eliminarUsuario(int id) async {
    await DatabaseHelper.instance.deleteUsuario(id);
    cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios (SQLite)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: saldoCtrl,
              decoration: const InputDecoration(labelText: "Saldo inicial"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: agregarUsuario, child: const Text("Agregar")),
            const SizedBox(height: 10),
            Expanded(
              child: usuarios.isEmpty
                  ? const Center(child: Text("No hay usuarios registrados"))
                  : ListView.builder(
                      itemCount: usuarios.length,
                      itemBuilder: (context, index) {
                        final u = usuarios[index];
                        return ListTile(
                          title: Text(u['nombre']),
                          subtitle: Text("Saldo: \$${u['saldo'].toStringAsFixed(2)}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => eliminarUsuario(u['id']),
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
