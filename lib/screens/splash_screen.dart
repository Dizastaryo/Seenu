import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:senu/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Задержка перед переходом на следующий экран
    await Future.delayed(Duration(seconds: 3));

    // Переход на следующий экран
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Белый фон
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie-анимция рисования сердца красной чернилой
          Container(
            height: 300,
            width: 300,
            child: Lottie.asset(
              'assets/animation/heart-ink-drawing.json', // Используем анимацию сердца, рисующегося с чернилами
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20),
          // Эффект 3D для текста "SeenU" с эффектом чернильных брызг
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.red, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'SeenU',
              style: TextStyle(
                fontSize: 60, // Увеличенный размер для акцента
                fontWeight: FontWeight.bold,
                fontFamily: 'DancingScript', // Каллиграфический шрифт
                color: Colors.white, // Белый цвет текста на градиенте
                shadows: [
                  Shadow(
                    offset: Offset(3.0, 3.0),
                    blurRadius: 6.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  Shadow(
                    offset: Offset(-3.0, -3.0),
                    blurRadius: 6.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
