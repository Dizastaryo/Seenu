import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

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
  bool _isOtpVerified = false;
  bool _isOtpSent = false;
  bool _isLoading = false;
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
    return Form(
      key: _formKeyRegister,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Поле ввода email
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

            // Логика отображения формы в зависимости от этапа
            if (!_isOtpSent)
              _buildActionButton(
                "Отправить OTP код",
                () async {
                  if (_formKeyRegister.currentState?.validate() ?? false) {
                    setState(() => _isLoading = true);
                    try {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .sendOtp(_emailController.text.trim());
                      setState(() => _isOtpSent = true);
                      _showSnackBar("OTP код отправлен на ваш email");
                    } catch (e) {
                      _showSnackBar("Ошибка: ${e.toString()}");
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
              ),

            if (_isOtpSent)
              Column(
                children: [
                  // Поле ввода OTP
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
                      if (_formKeyRegister.currentState?.validate() ?? false) {
                        setState(() => _isLoading = true);
                        try {
                          await Provider.of<AuthProvider>(context,
                                  listen: false)
                              .verifyOtp(
                            _emailController.text.trim(),
                            _otpController.text.trim(),
                          );
                          setState(() => _isOtpVerified = true);
                          _showSnackBar("OTP успешно проверен");
                        } catch (e) {
                          _showSnackBar("Ошибка: ${e.toString()}");
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                ],
              ),

            if (_isOtpVerified)
              Column(
                children: [
                  // Поле ввода логина
                  _buildTextField(
                    labelText: 'Логин',
                    icon: Icons.person_outline,
                    controller: TextEditingController(), // Добавьте управление
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите логин';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Поле ввода пароля
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
                    "Завершить регистрацию",
                    () async {
                      if (_formKeyRegister.currentState?.validate() ?? false) {
                        setState(() => _isLoading = true);
                        try {
                          await Provider.of<AuthProvider>(context,
                                  listen: false)
                              .signup(
                            _emailController.text.trim(),
                            'user', // Здесь можно добавить ввод имени пользователя
                            _passwordController.text.trim(),
                            _otpController.text.trim(),
                          );
                          Navigator.pushReplacementNamed(context, '/main');
                        } catch (e) {
                          _showSnackBar("Ошибка: ${e.toString()}");
                        } finally {
                          setState(() => _isLoading = false);
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
  }

  Widget _buildLoginTab() {
    return Form(
      key: _formKeyLogin,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              labelText: 'Email',
              icon: Icons.email,
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
                  setState(() => _isLoading = true);
                  try {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .login(_emailController.text.trim(),
                            _passwordController.text.trim());
                    Navigator.pushReplacementNamed(context, '/main');
                  } catch (e) {
                    _showSnackBar("Ошибка: ${e.toString()}");
                  } finally {
                    setState(() => _isLoading = false);
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
                child: Image.asset(
                  'assets/amanzat_logo.png',
                  width: 400,
                  height: 400,
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
          if (_isLoading)
            Center(
              child: Lottie.asset(
                'assets/animation/loading_animation.json',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
