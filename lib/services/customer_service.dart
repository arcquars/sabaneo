
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sabaneo_2/services/base_service.dart';
import 'package:sabaneo_2/services/config_service.dart';

class CustomerService extends BaseService {

  Future<void> createCustomer(String codigo, String nit, String razonSocial, String telefono, String tipoCliente, String coordenadas, String imageFile) async {
    debugPrint("Reee createCustomer::: $imageFile");
    final data = {
      "codigo": codigo,
      "nit": nit,
      "razonSocial": razonSocial,
      "celular": telefono,
      "tipoCliente": tipoCliente,
      "coordenadas": coordenadas,
      'image': imageFile,
    };
    try {
      Response response = await dio.post(
        "${ConfigService.apiBaseUrl}/ClienteApp.php", // Reemplaza con tu URL
        data: data,
        options: Options(
          headers: {
            // "Accept": "application/json",
            "Content-Type": "application/json",
          }, responseType: ResponseType.plain
        ),
      );
//
      if (response.statusCode == 200) {
        debugPrint("Imagen subida con éxito: ${response.data}");
      } else {
        debugPrint("Error al subir la imagen: ${response.statusCode}");
      }

    } on DioException catch (e) {
      debugPrint("Error CustomerService -> createCustomer -> ${e.error}");
    }
  }
}