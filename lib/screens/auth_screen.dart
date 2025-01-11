import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKeyRegister = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();

  bool _isPasswordVisible = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required String? Function(String?) validator,
    required TextEditingController controller,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle:
            TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.6)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildRegisterTab() {
    return Consumer<AuthProvider>(builder: (context, authProvider, child) {
      return Form(
        key: _formKeyRegister,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTextField(
                labelText: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (!authProvider.isOtpSent)
                _buildActionButton(
                  "Отправить OTP код",
                  () async {
                    if (_formKeyRegister.currentState?.validate() ?? false) {
                      try {
                        await authProvider
                            .sendOtp(_emailController.text.trim());
                        _showSnackBar("OTP код отправлен на ваш email");
                      } catch (e) {
                        _showSnackBar("Ошибка: ${e.toString()}");
                      }
                    }
                  },
                ),
              if (authProvider.isOtpSent)
                Column(
                  children: [
                    _buildTextField(
                      labelText: 'Введите OTP код',
                      icon: Icons.sms_outlined,
                      controller: _otpController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите код';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      "Проверить OTP",
                      () async {
                        if (_formKeyRegister.currentState?.validate() ??
                            false) {
                          try {
                            await authProvider.verifyOtp(
                              _emailController.text.trim(),
                              _otpController.text.trim(),
                            );
                            _showSnackBar("OTP успешно проверен");
                          } catch (e) {
                            _showSnackBar("Ошибка: ${e.toString()}");
                          }
                        }
                      },
                    ),
                  ],
                ),
              if (authProvider.isOtpVerified)
                Column(
                  children: [
                    _buildTextField(
                      labelText: 'Логин',
                      icon: Icons.person_outline,
                      controller: _loginController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите логин';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      labelText: 'Пароль',
                      icon: Icons.lock,
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      toggleVisibility: () {
                        setState(
                            () => _isPasswordVisible = !_isPasswordVisible);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен быть не менее 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      "Завершить регистрацию",
                      () async {
                        if (_formKeyRegister.currentState?.validate() ??
                            false) {
                          try {
                            await authProvider.signup(
                              _emailController.text.trim(),
                              _loginController.text.trim(),
                              _passwordController.text.trim(),
                              _otpController.text.trim(),
                            );
                            Navigator.pushReplacementNamed(context, '/main');
                          } catch (e) {
                            _showSnackBar("Ошибка: ${e.toString()}");
                          }
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoginTab() {
    return Form(
      key: _formKeyLogin,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              labelText: 'Логин',
              icon: Icons.person_outline,
              controller: _loginController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите логин';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              labelText: 'Пароль',
              icon: Icons.lock,
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              toggleVisibility: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите пароль';
                }
                if (value.length < 6) {
                  return 'Пароль должен быть не менее 6 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              "Войти",
              () async {
                if (_formKeyLogin.currentState?.validate() ?? false) {
                  try {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .login(
                      _loginController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    Navigator.pushReplacementNamed(context, '/main');
                  } catch (e) {
                    _showSnackBar("Ошибка: ${e.toString()}");
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Align(
            alignment: Alignment(0, 0.5),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Lottie.asset(
                  'assets/animations/pixelated-heart.json', // Анимация вместо изображения
                  width: 180, // Установим те же размеры
                  height: 180, // Установим те же размеры
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              Text(
                "Добро пожаловать!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor:
                    Theme.of(context).primaryColor.withOpacity(0.6),
                tabs: const [
                  Tab(text: 'Регистрация'),
                  Tab(text: 'Вход'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRegisterTab(),
                    _buildLoginTab(),
                  ],
                ),
              ),
            ],
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Lottie.asset(
                      'assets/animations/pixelated-heart.json',
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
