import 'package:dio/dio.dart';
import 'dio_client.dart';

class AuthService {
  final Dio dio;
  final DioClient dioClient;

  AuthService(this.dio, this.dioClient);

  Future<void> sendOtp(String email) async {
    try {
      final response = await dio.post('/auth/send-otp', data: {'email': email});
      if (response.statusCode == 200) {
        print('OTP sent to $email');
      } else {
        throw Exception('Error sending OTP: ${response.data}');
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
        print('OTP verified successfully');
      } else {
        throw Exception('Error verifying OTP: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(
      String email, String username, String password, String otp) async {
    try {
      // Завершаем регистрацию, передавая OTP и другие данные
      final response = await dio.post('/auth/signup', data: {
        'email': email,
        'username': username,
        'password': password,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        print('User registered successfully');
      } else {
        throw Exception('Error during signup: ${response.data}');
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
        await dioClient.saveAccessToken(data['accessToken']);
        await dioClient.saveRefreshToken(data['refreshToken']);
      } else {
        throw Exception('Login error: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await dioClient.getRefreshToken();
      if (refreshToken != null) {
        final response = await dio.post(
          '/auth/refresh',
          options: Options(
            headers: {
              'Cookie': 'refreshToken=$refreshToken'
            }, // передаем refresh token через cookies
          ),
        );
        if (response.statusCode == 200) {
          await dioClient.saveAccessToken(response.data['accessToken']);
          await dioClient.saveRefreshToken(response.data['refreshToken']);
          print('Tokens refreshed successfully');
        } else {
          throw Exception('Error refreshing token: ${response.data}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await dioClient.getRefreshToken();
      if (refreshToken != null) {
        await dio.post(
          '/auth/logout',
          options: Options(
            headers: {
              'Cookie': 'refreshToken=$refreshToken'
            }, // передаем refresh token через cookies
          ),
        );
        await dioClient.clearTokens();
        print('Logged out successfully');
      }
    } catch (e) {
      rethrow;
    }
  }
}
