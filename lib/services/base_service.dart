import 'package:dio/dio.dart';
import 'package:sabaneo_2/services/config_service.dart';

class BaseService {
  late Dio dio;

  BaseService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ConfigService.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> getRequest(String endpoint, {Map<String, dynamic>? params}) async {
    Response response = await dio.get(endpoint, queryParameters: params);
      return response;
  }

  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    Response response = await dio.post(endpoint, data: data);
      return response;
  }

  Future<Response> getTokenRequest(String endpoint, Map<String, dynamic> data, String token) async {
    Response response = await dio.get(
      endpoint, 
      data: data, 
      options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
    );
    return response;
  }

  Future<Response> postTokenRequest(String endpoint, Map<String, dynamic> data, String token) async {
    Response response = await dio.post(
      endpoint, 
      data: data, 
      options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
    );
    return response;
  }
}
