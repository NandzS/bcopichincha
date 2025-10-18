import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/colors.dart';

class HiveScreen extends StatefulWidget {
  const HiveScreen({super.key});

  @override
  State<HiveScreen> createState() => _HiveScreenState();
}

class _HiveScreenState extends State<HiveScreen> {
  late Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('config');
  }

  void cambiarModoOscuro(bool valor) {
    box.put('modoOscuro', valor);
  }

  void actualizarUltimoLogin() {
    final ahora = DateTime.now();
    box.put('ultimoLogin', ahora.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registro actualizado"),
        backgroundColor: AppColors.verdeexito,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        bool modoOscuro = box.get('modoOscuro', defaultValue: false);
        String ultimoLogin = box.get('ultimoLogin', defaultValue: 'N/A');

        DateTime? fechaHora;
        try {
          fechaHora = DateTime.parse(ultimoLogin);
        } catch (_) {
          fechaHora = null;
        }

        String fecha = fechaHora != null
            ? "${fechaHora.month}/${fechaHora.day}/${fechaHora.year}"
            : "N/A";
        String hora = fechaHora != null
            ? "${fechaHora.hour}:${fechaHora.minute.toString().padLeft(2, '0')}"
            : "N/A";

        // Colores modo oscuro
        Color bgColor = modoOscuro ? Colors.grey[850]! : AppColors.blancoapp;
        Color appBarColor = modoOscuro ? Colors.grey[850]! : AppColors.blancoapp;
        Color textColor = modoOscuro ? Colors.white : AppColors.azulMarino;
        Color cardColor = modoOscuro ? Colors.grey[800]! : Colors.white;
        Color iconColor = modoOscuro ? Colors.white : AppColors.azulMarino;
        Color borderColor = modoOscuro ? Colors.grey[700]! : const Color(0xFFE0E0E0);
        Color switchColor = modoOscuro ? Colors.white : AppColors.azulMarino;
        Color buttonBgColor = modoOscuro ? Colors.white : AppColors.azulMarino;
        Color buttonTextColor = modoOscuro ? Colors.black : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: appBarColor,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: iconColor),
            title: Text(
              "Configuraciones",
              style: TextStyle(color: textColor),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card modo oscuro / switch
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1),
                  ),
                  elevation: 4,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    activeColor: switchColor,
                    title: Text(
                      "Modo oscuro",
                      style: TextStyle(color: textColor, height: 1.2),
                    ),
                    value: modoOscuro,
                    onChanged: cambiarModoOscuro,
                  ),
                ),
                const SizedBox(height: 12),

                
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: actualizarUltimoLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonBgColor,
                              foregroundColor: buttonTextColor,
                              minimumSize: const Size(double.infinity, 48), 
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.2, 
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Actualizar último acceso"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Último acceso:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text("Fecha: $fecha", style: TextStyle(color: textColor, height: 1.2)),
                            const SizedBox(width: 24),
                            Text("Hora: $hora", style: TextStyle(color: textColor, height: 1.2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    leading: Icon(Icons.backup, color: iconColor),
                    title: Text(
                      "Respaldo de datos",
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, height: 1.2),
                    ),
                    subtitle: Text(
                      "Copia de seguridad local",
                      style: TextStyle(color: textColor.withOpacity(0.7), height: 1.2),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}