import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  ApiClient._internal(this.dio);
  factory ApiClient() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://restcountries.com/v3.1/',
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 5000),
    ));
    return ApiClient._internal(dio);
  }
}
