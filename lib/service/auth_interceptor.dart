import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final AuthProvider authProvider;

  AuthInterceptor(this.authProvider);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (authProvider.accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${authProvider.accessToken}';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await authProvider.refreshAccessToken();
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${authProvider.accessToken}';
        final response = await Dio().fetch(options);
        return handler.resolve(response);
      } catch (e) {
        // Обработка ошибки обновления токена
        return super.onError(err, handler);
      }
    }
    return super.onError(err, handler);
  }
}
