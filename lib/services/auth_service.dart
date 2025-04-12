import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sabaneo_2/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthService extends BaseService {

  Future<Map<String, dynamic>> login(String username, String password) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var bytes = utf8.encode(password);
    var digest = md5.convert(bytes);
    try {
      Response response = await postRequest(
        "/validarApp.php",
        {
          "login": username,
          "password": digest.toString(),
          "imei": androidInfo.id,
          "funcion": "login",
        }
      );

      if (response.data['error'] == "true") {  
        await prefs.setBool('isLoggedIn', true); // ✅ Guardamos la sesion
        await prefs.setString('token', response.data["token"]);
        await prefs.setString('empresa', response.data["empresa"]);
        await prefs.setString('idusuario', response.data["idusuario"]);
        return {
          "success": true,
          "message": response.data["mensaje"],
          "token": response.data["token"]
        };
      } else {
        await prefs.setBool('isLoggedIn', false); //
        return {"success": false, "message": response.data["mensaje"]};
      }
    } on DioException catch (e) {
      await prefs.setBool('isLoggedIn', false); //
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Error de conexión"
      };
    }
  }
}
