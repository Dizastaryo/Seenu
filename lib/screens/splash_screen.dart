import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:senu/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 10));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Фоновый градиент
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 255, 255, 255),
                  const Color.fromARGB(255, 255, 255, 255)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie-анимация
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 250,
                  width: 250,
                  child: Lottie.asset(
                    'assets/animation/hand-love.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Эффектный текст
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'SeenU',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DancingScript',
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 190, 2, 2),
                          const Color.fromARGB(255, 24, 8, 8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    shadows: [
                      Shadow(
                        offset: Offset(4.0, 4.0),
                        blurRadius: 8.0,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Дополнительный текст
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Feel the connection',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
