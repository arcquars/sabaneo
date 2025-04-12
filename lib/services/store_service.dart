
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sabaneo_2/models/caracteristica_model.dart';
import 'package:sabaneo_2/models/product_model.dart';
import 'package:sabaneo_2/models/store_model.dart';
import 'package:sabaneo_2/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreService extends BaseService {

  Future<List<Store>?> getStores() async {
    try {
      Response response = await getRequest(
        "/v1/stores/fetch-stores"
      );

      if(response.data['data'] != null){
        List<Store> stores = (response.data['data'] as List)
        .map((storeJson) => Store.fromJson(storeJson))
        .toList();

        return stores;
      } else {
        return null;
      }

    } on DioException catch (e) {
      debugPrint("Error StoreService -> getStores -> $e");
      return null;
    }


  }

  Future<List<Product>> getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');


    try {
      Response response = await postRequest(
        "/ProductoApp.php",
        {
          "idusuario": idusuario,
          "imei": "xxx",
          "empresa": empresa,
          "funcion": "findAllProductoConCaracteristicasApp",
          "token": token,
          "start":"0",
          "limit":"15",
          "sort":"codigo",
          "dir":"ASC",
          "codigo":"3872"
        }
      );

      if(response.data['error'] != "false"){
        var res = response.data['resultado'];
        List<Product> products = (res as List)
        .map((productJson) => Product.fromJson(productJson))
        .toList();
        var test = products.length;
        debugPrint("Productos12:: ${response.data['resultado']}");
        return products;
      } else {
        throw Exception('Error al cargar productos');
      }

    } on DioException catch (e) {
      debugPrint("Error StoreService -> getProducts -> $e");
      throw Exception('Error al cargar productos');
    }


  }

  Future<List<Product>> getProductsCar(Map<String, String> filters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');

    List<MapEntry<String, String>> propEntries = [];
    propEntries.add(MapEntry("idusuario", idusuario!));
    propEntries.add(MapEntry("empresa", empresa!));
    propEntries.add(MapEntry("funcion", "findAllProductoConCaracteristicasApp"));
    propEntries.add(MapEntry("token", token!));
    // propEntries.add(MapEntry("start", "0"));
    // propEntries.add(MapEntry("limit", "5"));
    propEntries.add(MapEntry("sort", "codigo"));
    propEntries.add(MapEntry("dir", "ASC"));

    filters.addEntries(propEntries);

    debugPrint("filtros:: $filters");
    try {
      Response response = await postRequest(
        "/ProductoApp.php",
        filters
      );

      if(response.data['error'] != "false"){
        var res = response.data['resultado'];
        List<Product> products = (res as List)
        .map((productJson) => Product.fromJson(productJson))
        .toList();
        var test = products.length;
        debugPrint("if:::: $test");
        debugPrint("Productos:: ${response.data['resultado']}");
        return products;
      } else {
        debugPrint("else::: $response");
        return [];
      }

    } on DioException catch (e) {
      debugPrint("Error StoreService -> getProducts -> $e");
      throw Exception('Error al cargar productos');
    }


  }

  Future<List<Caracteristica>> getCaracteristica() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idusuario = prefs.getString('idusuario');
    final empresa = prefs.getString('empresa');


    try {
      Response response = await postRequest(
        "/ProductoApp.php",
        {
          "idusuario": idusuario,
          "empresa": empresa,
          "funcion": "findCatSubcatCaracApp",
          "token": token
        }
      );

      debugPrint("eeeppoo:: $response");
      if(response.data['error'] != "false"){
        var res = response.data['caracteristicaM'];
        List<Caracteristica> caracteristicas = (res as List)
        .map((caracteristicaJson) => Caracteristica.fromJson(caracteristicaJson))
        .toList();
        if(caracteristicas.length > 5){
          caracteristicas = caracteristicas.take(5).toList();
        }
        return caracteristicas;
      } else {
        throw Exception('Error al cargar caracteristicas');
      }

    } on DioException catch (e) {
      debugPrint("Error StoreService -> getCaracteristica -> $e");
      throw Exception('Error al cargar Caracteristicas');
    }


  }
}