import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio dio;
  final CookieJar cookieJar;

  DioClient()
      : dio = Dio(BaseOptions(
          baseUrl: 'http://192.168.1.6:8081/api',
          connectTimeout: Duration(milliseconds: 5000),
          receiveTimeout: Duration(milliseconds: 3000),
        )),
        cookieJar = CookieJar() {
    dio.interceptors.add(CookieManager(
        cookieJar)); // Использование CookieManager для работы с cookies
    dio.interceptors.add(LogInterceptor(
        responseBody: true)); // Для логирования запросов и ответов
  }

  Dio get client => dio;

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
    await prefs.remove('accessToken');
  }
}
