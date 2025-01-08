import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart'; // Импортируем get_it
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/hearts_screen.dart';
import 'providers/auth_provider.dart';
import 'service/auth_service.dart';
import 'service/dio_client.dart';
import 'package:dio/dio.dart'; // Импортируем Dio

// Создаем экземпляр GetIt для централизованного управления зависимостями
final GetIt sl = GetIt.instance;

void main() {
  // Настроим все зависимости через get_it
  setupDependencies();

  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          sl<AuthProvider>(), // Извлекаем AuthProvider через get_it
      child: MyApp(),
    ),
  );
}

// Функция для настройки зависимостей
void setupDependencies() {
  // Регистрация DioClient
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Регистрация AuthService
  sl.registerLazySingleton<AuthService>(
      () => AuthService(sl<Dio>(), sl<DioClient>()));

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
        return _createScalePageRoute(SplashScreen());
      case '/auth':
        return _createScalePageRoute(const AuthScreen());
      case '/main':
        return _createScalePageRoute(const HomeScreen());
      case '/notifications':
        return _createScalePageRoute(const NotificationsScreen());
      case '/my-rentals':
        return _createScalePageRoute(HeartsScreen());
      default:
        return null;
    }
  }

  PageRouteBuilder _createScalePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween<double>(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }
}
