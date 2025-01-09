import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/hearts_screen.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'providers/auth_provider.dart';
import 'service/auth_service.dart';
import 'service/dio_client.dart';

final GetIt sl = GetIt.instance;
const String baseUrl = 'http://192.168.1.6:8081/api';

void main() {
  // Настройка зависимостей через get_it
  setupDependencies();

  runApp(
    ChangeNotifierProvider(
      create: (context) => sl<AuthProvider>(),
      child: MyApp(),
    ),
  );
}

// Функция для настройки зависимостей
void setupDependencies() {
  // Регистрация Dio
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      )));

  // Регистрация DioClient
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Dio>()));

  // Регистрация AuthService
  sl.registerLazySingleton<AuthService>(
      () => AuthService(sl<Dio>(), sl<DioClient>(), sl<CookieJar>()));

  // Регистрация AuthProvider
  sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<DioClient>(), sl<AuthService>()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Признавашки',
      theme: _buildThemeData(),
      initialRoute: '/splash',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: const Color(0xFF6C9942),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C9942),
        secondary: Color(0xFF4A6E2B),
      ),
      fontFamily: 'Montserrat',
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6C9942),
        foregroundColor: Colors.white,
        elevation: 5,
        centerTitle: true,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case '/auth':
        return MaterialPageRoute(builder: (context) => const AuthScreen());
      case '/main':
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case '/notifications':
        return MaterialPageRoute(
            builder: (context) => const NotificationsScreen());
      case '/hearts':
        return MaterialPageRoute(builder: (context) => HeartsScreen());
      default:
        return null;
    }
  }
}
