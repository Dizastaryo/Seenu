import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler package
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

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await _checkLocationPermission(); // Check permission on app start
  runApp(MyApp());
}

// Function to check and request location permission
Future<void> _checkLocationPermission() async {
  // Request location permission
  PermissionStatus status = await Permission.location.request();

  // If permission is denied, keep asking until granted
  if (status.isDenied || status.isPermanentlyDenied) {
    // Show a dialog asking the user to enable location permission
    bool shouldOpenSettings = await _showPermissionDialog();
    if (shouldOpenSettings) {
      openAppSettings(); // Open settings for the user to enable location manually
    }
    // Recursively check the permission again after the user is prompted
    await _checkLocationPermission();
  }
}

// Show a dialog asking the user to enable location permission
Future<bool> _showPermissionDialog() async {
  return await showDialog<bool>(
        context: sl.get(),
        builder: (context) {
          return AlertDialog(
            title: Text('Location Permission Required'),
            content: Text(
                'We need location access to continue. Please enable it in settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Go to Settings'),
              ),
            ],
          );
        },
      ) ??
      false;
}

class MyApp extends StatelessWidget {
  Future<void> _initializeDependencies() async {
    await setupDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeDependencies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Ошибка инициализации зависимостей')),
            ),
          );
        }

        return ChangeNotifierProvider(
          create: (context) => sl<AuthProvider>(),
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

Future<void> setupDependencies() async {
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      )));

  sl.registerLazySingleton<CookieJar>(() => CookieJar());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Dio>()));
  sl.registerLazySingleton<AuthService>(
      () => AuthService(sl<Dio>(), sl<DioClient>(), sl<CookieJar>()));
  sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<DioClient>(), sl<AuthService>()));
}
