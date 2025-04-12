import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sabaneo_2/models/user_model.dart';
import 'package:sabaneo_2/models/user_register_model.dart';
import 'package:sabaneo_2/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends BaseService {
  
  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString("empresa");
    debugPrint("TOKEN getUser():::: $token");
    
    try {
      Response response = await postRequest(
        "/validarApp.php",
        {
          "idusuario": idusuario,
          "token": token,
          "empresa": empresa,
          "funcion": "reiniciar"
        }
      );

      final errorTest = response.data['error'];
      debugPrint('test pdm 2.... $errorTest');
      if(errorTest != 'true'){
        _clearPreferencesApp();
        return null;
      }

      return User(id: response.data['idusuario'], name: response.data['nombre'], username: response.data['login'], role: response.data['rol']);
    } on DioException catch (e) {
      debugPrint("Error::: $e");
      _clearPreferencesApp();
      return null;
    }


  }

  Future<List<String>?> getRoles() async {
    try {
      Response response = await getRequest(
        "/v1/user/fetch-roles"
      );

      if(response.data['data'] != null){
        List<String> roles = List<String>.from(response.data['data']);
        return roles;
      } else {
        return null;
      }

    } on DioException catch (e) {
      debugPrint("Error: UserService :getRoles : $e");
      return null;
    }


  }

  // Simula la actualización de un usuario
  Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula un retraso de red
    // log('Usuario actualizado: ${user.name}');
  }

  Future<User?> validLogin(username, password) async {
    // Aquí podrías hacer una llamada HTTP a una API real
    await Future.delayed(const Duration(seconds: 1)); // Simula un retraso de red

    if (username.compareTo("arc") == 0  && password.compareTo("123") == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // ✅ Guardamos la sesion
      return User(id: "qqq", name: 'Pedro', username: 'arcquars1', email: 'arc.quars@lugubria.net', role: 'salesman');
    }
    
    return null;
  }

  Future<Map<String, dynamic>> createUser(UserRegister userRegister) async {
    try {
      Response response = await postRequest(
        "/v1/user/create",
        {
          "username": userRegister.username,
          "names": userRegister.name,
          "email": userRegister.email,
          "phone": userRegister.phone,
          "rol": userRegister.role,
          "store": userRegister.store
        }
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Se registro el usuario correctamente"
        };
      } else if (response.statusCode == 422) {
        // Errores de validación
        debugPrint("xxxxxxxxxxxxxxxxxxxxxxx");
        final Map<String, dynamic> respuestaData = json.decode(response.data);
        return {
          "success": false,
          "message": "Se tiene errores en el formulario",
          "errors": respuestaData['errors'] ?? {}
        };
      } else {
        return {"success": false, "message": "Datos de usuario incorrectas"};
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Errores de validación
        return {
          "success": false,
          "message": e.response?.data["message"] ?? "Error de conexión",
          "errors": e.response?.data['errors'] ?? {}
        };
      }
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Error de conexión"
      };
    }
  }

  Future<void> _clearPreferencesApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("isLoggedIn");
    prefs.remove("token");
    prefs.remove("empresa");
    prefs.remove("idusuario");
  }
}