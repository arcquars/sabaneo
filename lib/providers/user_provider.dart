import 'package:flutter/material.dart';
import 'package:sabaneo_2/models/user_model.dart';
import 'package:sabaneo_2/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _name;
  String? _username;
  String? _role;
  bool _isLoggedIn = false;

  String? get name => _name;
  String? get username => _username;
  String? get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  // ✅ Cargar sesión desde SharedPreferences
  Future<void> loadUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn1 = prefs.getBool('isLoggedIn') ?? false;

    debugPrint("Dentro de UserProvider - loadUserSession::: $isLoggedIn1");
    // Actualizar datos del usuario
    if(isLoggedIn1){
      final UserService userService = UserService();
      final User? user = await userService.getUser();
      if(user != null){
        _isLoggedIn = true;
        login(user.name, user.username, user.email, user.role);
        // _name = prefs.getString('name');
        // _username = prefs.getString('username');
        // _role = prefs.getString('role');
        // _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      } else {
        // prefs.clear();
        // prefs.setBool("isLoggedIn", false);
        logout();
      }
    }
  }

  Future<bool> isUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn1 = prefs.getBool('isLoggedIn') ?? false;

    debugPrint("Dentro de UserProvider - loadUserSession::: $isLoggedIn1");
    // Actualizar datos del usuario
    if(isLoggedIn1){
      final UserService userService = UserService();
      final User? user = await userService.getUser();
      if(user != null){
        login(user.name, user.username, user.email, user.role);
        return true;
      }
    }
    logout();
    return false;
  }

  // ✅ Guardar sesión después del login
  Future<void> login(String name, String username, String? email, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('username', username);
    await prefs.setString('role', role);
    await prefs.setBool('isLoggedIn', true);

    _name = name;
    _username = username;
    _role = role;
    _isLoggedIn = true;
    notifyListeners();
  }

  // ✅ Cerrar sesión (logout)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ❌ Borra la sesión almacenada

    _name = null;
    _username = null;
    _role = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
