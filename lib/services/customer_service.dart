
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

  Future<String> createCustomer(
      String idcliente,
      String idpersona,
      String codigo,
      String documentType,
      String nit,
      String complemento,
      String razonSocial,
      String telefono,
      String direccion,
      String representantelegal,
      String tipoCliente,
      String latitud,
      String longitud,
      String imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');

    debugPrint("Reee createCustomer::: $imageFile");
    final data = {
      "idcliente": idcliente,
      "idpersona": idpersona,
      "codigo": codigo,
      "tipodoc": documentType,
      "complemento": complemento,
      "nit": nit,
      "razonSocial": razonSocial,
      "celular": telefono,
      "direccion": direccion,
      "representantelegal": representantelegal,
      "tipocliente": tipoCliente,
      "latitud": latitud,
      "longitud": longitud,
      'image': imageFile,
      "token": token,
      "empresa": empresa,
      "idusuario": idusuario,
      'funcion': 'txSaveUpdateClienteApp',
    };
    try {
      Response response = await dio.post(
        "${ConfigService.apiBaseUrl}/ClienteApp.php", // Reemplaza con tu URL
        data: data,
        options: Options(
          headers: {
            // "Accept": "application/json",
            // "Content-Type": "application/json",
          },
            // responseType: ResponseType.plain
        ),
      );
      debugPrint("Imagen subida con éxito 0: ${data}");
      debugPrint("Imagen subida con éxito 0.2: ${response}");
      final errorTest = response.data['error'];
      if (errorTest != 'true') {
        debugPrint("Imagen subida con éxito 1: IF");
        return response.data['mensaje'];
      } else {
        debugPrint("Imagen subida con éxito 2: ELSE");
        throw Exception("${response.data['mensaje']}");
      }
    } on DioException catch (e) {
      debugPrint("Imagen subida con éxito 3:");
      // return e.error.toString();
      throw Exception("${e.error.toString()}");
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

    debugPrint("filtros 1:: $filters");
    try {
      Response response = await postRequest(
          "/ClienteApp.php",
          filters
      );
      debugPrint("filtros 2:: $response");
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
      debugPrint("Error StoreService -> getCustomers -> ${e.error}");
      throw Exception('Error al cargar clientes');
    }
  }

  Future<CustomerModel?> getCustomer(Map<String, String> filters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');

    List<MapEntry<String, String>> propEntries = [];
    propEntries.add(MapEntry("idusuario", idusuario!));
    propEntries.add(MapEntry("empresa", empresa!));
    propEntries.add(MapEntry("funcion", "findClienteByIdClienteApp"));
    propEntries.add(MapEntry("token", token!));

    filters.addEntries(propEntries);

    debugPrint("filtros getCustomer:: $filters");
    try {
      Response response = await postRequest(
          "/ClienteApp.php",
          filters
      );
      debugPrint("Cliente 5550: ${response.data}");
      if(response.data['error'] != "false"){
        var res = response.data['resultado'];
        CustomerModel customer = CustomerModel.fromJson(res);
        return customer;
      } else {
        debugPrint("else::: $response");
        return null;
      }

    } on DioException catch (e) {
      debugPrint("Error CustomerService -> getCustomer -> $e");
      throw Exception('Error al cargar Customer');
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