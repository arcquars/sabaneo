
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sabaneo_2/models/customer_model.dart';
import 'package:sabaneo_2/models/customer_type_model.dart';
import 'package:sabaneo_2/services/base_service.dart';
import 'package:sabaneo_2/services/config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService extends BaseService {

  Future<void> createCustomer(String codigo, String nit, String razonSocial, String telefono, String tipoCliente, String coordenadas, String imageFile) async {
    debugPrint("Reee createCustomer::: $imageFile");
    final data = {
      "idcliente": "nuevo",
      "codigo": codigo,
      "nit": nit,
      "razonSocial": razonSocial,
      "celular": telefono,
      "tipocliente": tipoCliente,
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

  Future<List<CustomerModel>> getCustomers(Map<String, String> filters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');

    List<MapEntry<String, String>> propEntries = [];
    propEntries.add(MapEntry("idusuario", idusuario!));
    propEntries.add(MapEntry("empresa", empresa!));
    propEntries.add(MapEntry("funcion", "findAllClienteApp"));
    propEntries.add(MapEntry("token", token!));
    propEntries.add(MapEntry("sort", "codigo"));
    propEntries.add(MapEntry("dir", "ASC"));

    filters.addEntries(propEntries);

    debugPrint("filtros:: $filters");
    try {
      Response response = await postRequest(
          "/ClienteApp.php",
          filters
      );

      if(response.data['error'] != "false"){
        var res = response.data['resultado'];
        List<CustomerModel> customers = (res as List)
            .map((customerJson) => CustomerModel.fromJson(customerJson))
            .toList();
        var test = customers.length;
        debugPrint("if:::: $test");
        debugPrint("Clientes:: ${response.data['resultado']}");
        return customers;
      } else {
        debugPrint("else::: $response");
        return [];
      }

    } on DioException catch (e) {
      debugPrint("Error StoreService -> getProducts -> $e");
      throw Exception('Error al cargar productos');
    }
  }

  Future<List<CustomerTypeModel>> getCustomerTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');

    try {
      Response response = await postRequest(
          "/ClienteApp.php",
          {
            "idusuario": idusuario,
            "empresa": empresa,
            "funcion": "findAllDataMapaApp",
            "token": token,
          }
      );

      if(response.data['error'] != "false"){
        var res = response.data['resultado'];
        List<CustomerTypeModel> customers = (res as List)
            .map((customerJson) => CustomerTypeModel.fromJson(customerJson))
            .toList();
        var test = customers.length;
        debugPrint("if:::: $test");
        debugPrint("ClientesTipos:: ${response.data['resultado']}");
        return customers;
      } else {
        debugPrint("else::: $response");
        return [];
      }

    } on DioException catch (e) {
      debugPrint("Error CustomerService -> getCustomerTypes -> $e");
      throw Exception('Error al cargar los tipos de clientes');
    }
  }
}