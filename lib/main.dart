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
const String baseUrl = 'http://192.168.1.3:8081/api';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Метод для асинхронной инициализации зависимостей
  Future<void> _initializeDependencies() async {
    await setupDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeDependencies(), // Инициализация зависимостей
      builder: (context, snapshot) {
        // Если зависимостей еще нет, показываем экран загрузки
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Если произошла ошибка при инициализации, показываем сообщение об ошибке
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Ошибка инициализации зависимостей')),
            ),
          );
        }

        // Когда зависимости инициализированы, запускаем основное приложение
        return ChangeNotifierProvider(
          create: (context) => sl<AuthProvider>(), // Инициализация AuthProvider
          child: MaterialApp(
            title: 'Признавашки',
            theme: _buildThemeData(),
            initialRoute: '/splash',
            onGenerateRoute: _onGenerateRoute,
          ),
        );
      },
    );
  }

  // Функция для настройки темы
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

  // Функция для обработки маршрутов
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case '/main':
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case '/auth':
        return MaterialPageRoute(builder: (context) => const AuthScreen());
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

// Функция для настройки зависимостей
Future<void> setupDependencies() async {
  // Регистрация Dio
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      )));

  // Регистрация CookieJar
  sl.registerLazySingleton<CookieJar>(() => CookieJar());

  // Регистрация DioClient
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Dio>()));

  // Регистрация AuthService
  sl.registerLazySingleton<AuthService>(
      () => AuthService(sl<Dio>(), sl<DioClient>(), sl<CookieJar>()));

  // Регистрация AuthProvider
  sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<DioClient>(), sl<AuthService>()));
}
