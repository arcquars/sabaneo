import 'package:flutter/material.dart';

class SabaneoInputDecoration {
  static InputDecoration textFieldStyle({String hintText = "", IconData? icon, String? errorText}) {
    icon = icon?? Icons.person_2_outlined;
    
    return InputDecoration(
      prefixIcon: Icon(icon),
                    labelText: hintText,
                    errorText: errorText,
                    hintText: "",
                    border: InputBorder.none,
    );
  }
}
