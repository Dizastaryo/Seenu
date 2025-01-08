import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; // Для логирования ошибок
import '../service/auth_service.dart';
import '../service/dio_client.dart';

class AuthProvider extends ChangeNotifier {
  final DioClient dioClient;
  final AuthService authService;

  String? _accessToken;
  String? _refreshToken;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;

  AuthProvider(this.dioClient, this.authService) {
    _loadTokens();
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken != null && !isTokenExpired();

  Future<void> _loadTokens() async {
    _setLoading(true);
    try {
      final accessToken = await dioClient.getAccessToken();
      final refreshToken = await dioClient.getRefreshToken();

      if (accessToken != _accessToken || refreshToken != _refreshToken) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;

        if (_accessToken != null && !isTokenExpired()) {
          notifyListeners();
        } else {
          await _handleTokenExpiration();
        }
      }
    } catch (e) {
      Sentry.captureException(e); // Log error
    } finally {
      _setLoading(false);
    }
  }

  bool isTokenExpired() {
    try {
      if (_accessToken == null) {
        return true;
      }
      return JwtDecoder.isExpired(_accessToken!);
    } catch (e) {
      return true;
    }
  }

  Future<void> _handleTokenExpiration() async {
    if (_refreshToken != null) {
      try {
        await refreshAccessToken();
      } catch (e) {
        await logout();
      }
    } else {
      await logout();
    }
  }

  Map<String, String> get currentUser {
    if (_accessToken == null || isTokenExpired()) {
      return {};
    }
    final decodedToken = JwtDecoder.decode(_accessToken!);
    return {
      'username': decodedToken['username'] ?? 'Неизвестный пользователь',
      'email': decodedToken['email'] ?? 'Неизвестный email',
      'avatarUrl':
          decodedToken['avatarUrl'], // Можно добавить аватар, если есть
    };
  }

  Future<void> signup(
      String email, String username, String password, String otp) async {
    _setLoading(true);
    try {
      await authService.signup(email, username, password, otp);
      print('Пользователь успешно зарегистрирован');

      // После успешной регистрации сразу выполняем вход
      await login(username, password); // Вход с теми же данными
    } catch (e) {
      Sentry.captureException(e); // Логирование ошибки
      throw Exception('Ошибка при регистрации: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    try {
      await authService.login(username, password);
      _accessToken = await dioClient.getAccessToken();
      _refreshToken = await dioClient.getRefreshToken();
      notifyListeners();
    } catch (e) {
      Sentry.captureException(e); // Log error
      throw Exception('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendOtp(String email) async {
    _setLoading(true);
    try {
      await authService.sendOtp(email);
      _isOtpSent = true;
      notifyListeners();
    } catch (e) {
      _isOtpSent = false;
      Sentry.captureException(e); // Log error
      throw Exception('Failed to send OTP: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    _setLoading(true);
    try {
      await authService.verifyOtp(email, otp);
      _isOtpVerified = true;
      notifyListeners();
    } catch (e) {
      Sentry.captureException(e); // Log error
      throw Exception('Failed to verify OTP: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshAccessToken() async {
    _setLoading(true);
    try {
      await authService.refreshAccessToken();
      _accessToken = await dioClient.getAccessToken();
      _refreshToken = await dioClient.getRefreshToken();
      notifyListeners();
    } catch (e) {
      Sentry.captureException(e); // Log error
      throw Exception('Error refreshing token: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await authService.logout();
      _accessToken = null;
      _refreshToken = null;
      await dioClient.clearTokens();
      notifyListeners();
    } catch (e) {
      Sentry.captureException(e); // Log error
      throw Exception('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> autoLogin() async {
    await _loadTokens();
    if (!isAuthenticated) {
      throw Exception("User is not authenticated.");
    } else {
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
