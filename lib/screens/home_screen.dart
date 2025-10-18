import 'package:bcopichincha/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/balance_service.dart';
import '../db/database_helper.dart'; 
import '../screens/deposit_screen.dart';
import '../screens/withdraw_screen.dart';
import '../services/firebase_service.dart'; 
import '../screens/settings_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _usuarios = [];

  int _selectedIndex = 0; 
  
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BalanceService>().initService();
    });
    _loadUsuarios();

    
    _screens.addAll([
      _HomeMainContent(
        addUser: _addUser,
        showUsers: _showUsers,
        logout: _logout,
      ),
      const SettingsScreen(),
    ]);
  }

  Future<void> _loadUsuarios() async {
    try {
      final data = await DatabaseHelper.instance.getUsuarios();
      if (!mounted) return;
      setState(() {
        _usuarios = data;
      });
    } catch (e) {
      print('Error al cargar usuarios locales: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advertencia: Error al cargar DB local')),
      );
    }
  }

  Future<void> _addUser() async {
  final nombreCtrl = TextEditingController();
  final saldoCtrl = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.blancoapp,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.plomoapp, width: 1),
        ),
        title: Text(
          'Agregar Usuario (DB Local)',
          style: const TextStyle(
            color: AppColors.azulMarino,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: AppColors.azulMarino),
              ),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: saldoCtrl,
              decoration: const InputDecoration(
                labelText: 'Saldo inicial',
                labelStyle: TextStyle(color: AppColors.azulMarino),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.azulMarino),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azulMarino,
            ),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final saldo = double.tryParse(saldoCtrl.text.trim()) ?? 0.0;
              if (nombre.isEmpty) return;
              try {
                await DatabaseHelper.instance.insertUsuario({'nombre': nombre, 'saldo': saldo});
                if (!mounted) return;
                Navigator.pop(context, true);
              } catch (e) {
                print('Error al insertar usuario local: $e');
                if (!mounted) return;
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al agregar usuario.')),
                );
              }
            },
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

  if (result == true) {
    await _loadUsuarios();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario agregado correctamente')),
    );
  }
}

 Future<void> _showUsers() async {
  await _loadUsuarios();
  if (!mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.blancoapp,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.plomoapp, width: 1),
        ),
        title: const Text(
          'Usuarios (DB Local)',
          style: TextStyle(
            color: AppColors.azulMarino,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _usuarios.isEmpty
              ? const Text(
                  'No hay usuarios registrados.',
                  style: TextStyle(color: AppColors.azulMarino),
                )
              : StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _usuarios.map((user) {
                          return ListTile(
                            key: ValueKey(user['id']),
                            title: Text(
                              user['nombre'],
                              style: const TextStyle(color: AppColors.azulMarino),
                            ),
                            subtitle: Text(
                              'Saldo: \$${(user['saldo'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.azulMarino),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await DatabaseHelper.instance.deleteUsuario(user['id']);
                                  final data = await DatabaseHelper.instance.getUsuarios();
                                  setStateDialog(() {
                                    _usuarios = data;
                                  });
                                  _loadUsuarios();
                                } catch (e) {
                                  print('Error al eliminar usuario local: $e');
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Error al eliminar usuario')),
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: AppColors.azulMarino),
            ),
          ),
        ],
      );
    },
  );
}

  void _logout() async {
    await FirebaseService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: _screens[_selectedIndex],
    bottomNavigationBar: Material(
      elevation: 4, 
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.3), 
              width: 0.8,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.blancoapp,
          elevation: 0, 
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: AppColors.azulMarino.withOpacity(0.1),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.azulMarino),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.azulMarino),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _HomeMainContent extends StatelessWidget {
  final VoidCallback addUser;
  final VoidCallback showUsers;
  final VoidCallback logout;

  const _HomeMainContent({
    required this.addUser,
    required this.showUsers,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    final balanceService = Provider.of<BalanceService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blancoapp,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/bcopichincha_logo.png', height: 26),
            IconButton(
  icon: const Icon(Icons.exit_to_app, color: AppColors.azulMarino),
  tooltip: 'Cerrar Sesión',
  onPressed: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.blancoapp,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppColors.plomoapp, width: 1),
      ),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(
          color: AppColors.azulMarino,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        '¿Estás seguro de que deseas cerrar sesión?',
        style: TextStyle(color: AppColors.azulMarino),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      actionsPadding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.azulMarino,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulMarino,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                logout();
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
},
),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      bottom: 16,
                      right: 96,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Fácil, rápido y seguro',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulMarino,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Con Banca móvil gestiona tu banco donde quieras',
                            style: TextStyle(fontSize: 14, color: AppColors.plomoapp),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/banca_imagen.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 7.5),
              child: Text(
                'Mis Productos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
            ),
            ),

            const SizedBox(height: 10),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tu Saldo Actual', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        '\$${balanceService.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 7.5),
              child: Text(
                'Qué deseas hacer hoy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MenuCard(
                  title: 'Transferir / Depositar',
                  icon: Icons.account_balance_wallet,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen()));
                  },
                ),
                _MenuCard(
                  title: 'Retirar',
                  icon: Icons.money_off,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen()));
                  },
                ),
                _MenuCard(title: 'Registrar Usuario\n(Local)', icon: Icons.person_add, onTap: addUser),
                _MenuCard(title: 'Mostrar Usuarios\n(Local)', icon: Icons.list_alt, onTap: showUsers),
                _MenuCard(
                  title: 'Historial',
                  icon: Icons.history,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad de Historial Próximamente.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSize = constraints.maxWidth * 0.35;
        final double fontSize = constraints.maxWidth * 0.1;

        return GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 4,
                    child: Icon(icon, size: iconSize, color: AppColors.azulMarino),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    flex: 3,
                    child: Text(
                      title,
                      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}