import 'package:flutter/material.dart';
import 'hive_screen.dart';
import '../core/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  bool _notificacionesActivadas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blancoapp,
      appBar: AppBar(
        backgroundColor: AppColors.blancoapp,
        elevation: 0,
        title: const Text(
          'Ajustes',
          style: TextStyle(color: AppColors.azulMarino),
        ),
        iconTheme: const IconThemeData(color: AppColors.azulMarino),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.azulMarino),
              title: const Text(
                'Notificaciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Activar o desactivar alertas'),
              trailing: Switch(
                value: _notificacionesActivadas,
                activeColor: AppColors.azulMarino,
                onChanged: (val) {
                  setState(() {
                    _notificacionesActivadas = val; 
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

         
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.storage, color: AppColors.azulMarino),
              title: const Text(
                'Configuraciones de la app',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Modo oscuro, último login...'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HiveScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.person, color: AppColors.azulMarino),
              title: const Text(
                'Perfil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Editar información de usuario'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),

          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.info, color: AppColors.azulMarino),
              title: const Text(
                'Acerca de',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Versión, créditos, ayuda'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),

       
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.support, color: AppColors.azulMarino),
              title: const Text(
                'Soporte y ayuda',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Contacta con nuestro equipo'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}