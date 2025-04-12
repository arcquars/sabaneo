import 'package:flutter/material.dart';

class SabaneoButtonStyles {
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffe8a63f),
      foregroundColor: Colors.white,
      side: const BorderSide(
        color: Color(0xffe86d3f), // Color del borde
        width: 1.0, // Ancho del borde
      ),
    );
  }

  // Puedes agregar más estilos predefinidos para otros ElevatedButton según tus necesidades
  static ButtonStyle secondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffe86d3f),
      foregroundColor: Colors.white,
      side: const BorderSide(
        color: Color(0xffe8a63f), // Color del borde
        width: 1.0, // Ancho del borde
      ),
    );
  }
}
