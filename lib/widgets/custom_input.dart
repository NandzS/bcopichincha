
import 'package:flutter/material.dart';
import '../core/colors.dart'; 

class CustomInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Color iconColor;
  final Color? fillColor; 
  final Color? textColor; 

  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    required this.icon,
    this.iconColor = Colors.blue,
    this.fillColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: textColor ?? Colors.black, 
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor),
          hintText: hintText,
          hintStyle: TextStyle(
            color: (textColor ?? Colors.black).withOpacity(0.5),
          ),
          filled: true,
          fillColor: fillColor ?? Colors.grey[200], 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.azulMarino,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}