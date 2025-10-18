import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/deposit_screen.dart';
import 'services/balance_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/services.dart';
import 'core/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.blancoapp, 
    statusBarIconBrightness: Brightness.dark, 
    statusBarBrightness: Brightness.light, 
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  
  await Hive.initFlutter();
  await Hive.openBox('config'); 

  runApp(
    ChangeNotifierProvider(
      create: (_) => BalanceService(),
      child: const CajeroApp(),
    ),
  );
}

class CajeroApp extends StatelessWidget {
  const CajeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final configBox = Hive.box('config');
    bool modoOscuro = configBox.get('modoOscuro', defaultValue: false);

    return ValueListenableBuilder(
      valueListenable: configBox.listenable(),
      builder: (context, Box box, _) {
        modoOscuro = box.get('modoOscuro', defaultValue: false);
        return MaterialApp(
          title: 'Banco Pichincha',
          debugShowCheckedModeBanner: false,
          theme: modoOscuro ? ThemeData.dark() : appTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/deposit': (context) => DepositScreen(),
          },
        );
      },
    );
  }
}
