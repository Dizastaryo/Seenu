import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dio_client.dart';

class AuthService {
  final Dio dio;
  final DioClient dioClient;
  final CookieJar cookieJar;

  AuthService(this.dio, this.dioClient, this.cookieJar);

  Future<void> sendOtp(String email) async {
    try {
      final response = await dio.post('/auth/send-otp', data: {'email': email});
      if (response.statusCode == 200) {
        print('OTP отправлен на $email');
      } else {
        throw Exception('Ошибка при отправке OTP: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      final response = await dio
          .post('/auth/verify-otp', data: {'email': email, 'otp': otp});
      if (response.statusCode == 200) {
        print('OTP успешно подтверждён');
      } else {
        throw Exception('Ошибка при подтверждении OTP: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(
      String email, String username, String password, String otp) async {
    try {
      final response = await dio.post('/auth/signup', data: {
        'email': email,
        'username': username,
        'password': password,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        print('Пользователь успешно зарегистрирован');
      } else {
        throw Exception('Ошибка при регистрации: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await dio.post('/auth/signin',
          data: {'username': username, 'password': password});
      if (response.statusCode == 200) {
        final data = response.data;

        // Сохраняем access token
        await dioClient.saveAccessToken(data['accessToken']);

        // Извлекаем куки через cookieJar
        final cookies = await cookieJar
            .loadForRequest(Uri.parse('${dio.options.baseUrl}/auth/signin'));
        if (cookies.isEmpty) {
          throw Exception('Куки не найдены после логина');
        }

        final refreshTokenCookie = cookies.firstWhere(
          (cookie) => cookie.name == 'refreshToken',
        );
        if (refreshTokenCookie.name.isNotEmpty) {
          // Сохраняем refresh token
          await dioClient.saveRefreshToken(refreshTokenCookie.value);
        } else {
          throw Exception('Отсутствует refresh token в куки');
        }
      } else {
        throw Exception('Ошибка при логине: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshAccessToken() async {
    try {
      // Получаем refresh token из dioClient (если он уже сохранён)
      final refreshToken = await dioClient.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Нет доступного refresh токена');
      }

      // Отправляем запрос на обновление токена
      final response = await dio.post(
        '/auth/refresh',
        options: Options(headers: {'Cookie': 'refreshToken=$refreshToken'}),
      );
      if (response.statusCode == 200) {
        await dioClient.saveAccessToken(response.data['accessToken']);
        await dioClient.saveRefreshToken(response.data['refreshToken']);
        print('Токены успешно обновлены');
      } else {
        throw Exception('Ошибка при обновлении токена: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Получаем refresh token из dioClient (если он уже сохранён)
      final refreshToken = await dioClient.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Нет refresh токена для выхода');
      }

      // Отправляем запрос на выход
      await dio.post('/auth/logout',
          options: Options(headers: {
            'Cookie': 'refreshToken=$refreshToken',
          }));

      // Очищаем все токены
      await dioClient.clearTokens();
      print('Выход выполнен успешно');
    } catch (e) {
      rethrow;
    }
  }
}
