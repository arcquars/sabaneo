import 'package:flutter/material.dart';

class SabaneoInputDecoration {
  static InputDecoration defaultDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(), // Borde por defecto
      focusedBorder: const OutlineInputBorder( // Borde cuando está activo
        borderSide: BorderSide(color: Color(0xffe8a63f), width: 2.0),
      ),
      labelStyle: const TextStyle(color: Colors.grey), // Estilo por defecto del label
      floatingLabelStyle: const TextStyle(color: Color(0xffe8bb3f)), // Estilo del label cuando está activo
        contentPadding: const EdgeInsets.all(8.0)
    );
  }

  static InputDecoration defaultDecorationSuffixIcon({
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
    VoidCallback? onPressedSuffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xffe8a63f), width: 2.0),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Color(0xffe8bb3f)),
      suffixIcon: suffixIcon != null
          ? IconButton(
        icon: suffixIcon,
        onPressed: onPressedSuffixIcon,
      )
          : null,
    );
  }

  static InputDecoration errorDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)), // Borde de error
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      labelStyle: const TextStyle(color: Colors.red), // Estilo del label de error
      floatingLabelStyle: const TextStyle(color: Colors.red), // Estilo del label de error activo
    );
  }

// Puedes agregar más decoraciones predefinidas según tus necesidades
}