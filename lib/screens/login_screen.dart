import 'package:bcopichincha/core/colors.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_input.dart';
import 'package:audioplayers/audioplayers.dart';
import 'animation_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  void _login() async {
    final email = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, complete todos los campos")),
      );
      return;
    }

    String? error = await _firebaseService.login(email, password);

    if (error == null) {

      
      String nombreCompletoDelUsuario = await _firebaseService.getNombreCompleto(email);

  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) =>  AnimationScreen(usuarioCompleto: nombreCompletoDelUsuario)),
  );
}
 else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _goToRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( 
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Image.asset(
                  'assets/images/bcopichincha_logo.png',
                  height: 60,
                ),

               

                
                Image.asset(
                  'assets/images/logingif.gif',
                  height: 250, 
                ),

              

                
                CustomInput(
                  controller: _userController,
                  hintText: 'Correo electrónico',
                  icon: Icons.person,
                  iconColor: AppColors.azulMarino,
                ),

                
                CustomInput(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  icon: Icons.lock,
                  iconColor: AppColors.azulMarino,
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Iniciar Sesión'),
                ),

                const SizedBox(height: 10),

                
                TextButton(
                  onPressed: _goToRegistro,
                  child: const Text(
                    "¿No tienes cuenta? Regístrate",
                    style: TextStyle(
                      color: AppColors.celesteclaro,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                
                Text( 
                  "Versión 1.2.0", 
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;

  void _registrar() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();

    if (email.isEmpty || password.isEmpty || nombre.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, complete todos los campos"),
          backgroundColor: AppColors.rojoerror,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden"),
          backgroundColor: AppColors.rojoerror,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? error = await _firebaseService.registrar(email, password, nombre);

    setState(() => _isLoading = false);

    if (error == null) {
      final player = AudioPlayer();
      await player.play(AssetSource('audios/exito.mp3'));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso", textAlign: TextAlign.center,), backgroundColor: AppColors.verdeexito,),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  
  final bool modoOscuro = Hive.box('config').get('modoOscuro', defaultValue: false);

  // Colores
  final Color background = modoOscuro ? Colors.black : AppColors.blancoapp;
  final Color textColor = modoOscuro ? Colors.white : AppColors.azulMarino;
  final Color inputFill = modoOscuro ? Colors.grey[850]! : Colors.grey[200]!; // fondo del input
  final Color buttonBg = modoOscuro ? AppColors.azulMarino : Colors.white;
  final Color buttonText = modoOscuro ? Colors.white : AppColors.azulMarino;

  return Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: background,
    extendBodyBehindAppBar: false,
    appBar: AppBar(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Únete a Banco Pichincha',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Image.asset(
                'assets/images/bp_optimismo.png',
                height: 200,
              ),

              
              CustomInput(
                controller: _nombreCtrl,
                hintText: 'Nombre Completo',
                icon: Icons.person,
                iconColor: textColor,
                fillColor: inputFill,
                textColor: textColor,
              ),
              CustomInput(
                controller: _emailCtrl,
                hintText: 'Correo electrónico',
                icon: Icons.email,
                iconColor: textColor,
                fillColor: inputFill,
                textColor: textColor,
              ),
              CustomInput(
                controller: _passwordCtrl,
                hintText: 'Contraseña',
                icon: Icons.lock,
                iconColor: textColor,
                obscureText: true,
                fillColor: inputFill,
                textColor: textColor,
              ),
              CustomInput(
                controller: _confirmPasswordCtrl,
                hintText: 'Confirmar contraseña',
                icon: Icons.lock,
                iconColor: textColor,
                obscureText: true,
                fillColor: inputFill,
                textColor: textColor,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus(); 
                  _registrar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: buttonText,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.azulMarino,
              ),
            ),
          ),
      ],
    ),
  );
}

}