//colores, estilos y temas de la app
import 'package:bcopichincha/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


final ThemeData appTheme = ThemeData(
  
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: AppColors.blancoapp,

  appBarTheme: const AppBarTheme(
    color: AppColors.blancoapp,
    foregroundColor: Colors.black,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: AppColors.blancoapp, 
      statusBarIconBrightness: Brightness.dark, 
      statusBarBrightness: Brightness.light, 
    ),
  ),

  
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.azulMarino, 
    selectionColor: AppColors.azulMarino.withOpacity(0.3), 
    selectionHandleColor: AppColors.azulMarino, 
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: AppColors.azulMarino, 
        width: 1.5,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: Colors.transparent, 
      ),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.blancoapp,
      foregroundColor: AppColors.azulMarino,
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),

  
  cardTheme: CardThemeData(
    color: AppColors.blancoapp, 
    shadowColor: Colors.black.withOpacity(0.2),
    elevation: 6, 
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    ),
  ),

  
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.plomoapp, fontSize: 14),
  ),


);