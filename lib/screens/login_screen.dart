import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:runner_sync_app/models/user.dart';
import 'package:runner_sync_app/screens/home_screen.dart';
import 'package:runner_sync_app/screens/register_screen.dart';
import 'package:runner_sync_app/screens/tabbar_screen.dart';
import 'package:runner_sync_app/utils/database_service.dart';
import 'package:runner_sync_app/utils/validators.dart';
import 'package:runner_sync_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isAgreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // if (!_isAgreedToTerms) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('请先同意用户协议'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    userLogin(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo 和标题
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 32),

                Text(
                  '用户登录',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // 登录表单
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 邮箱输入框
                      CustomTextField(
                        controller: _emailController,
                        labelText: '邮箱地址',
                        hintText: '请输入您的邮箱地址',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),

                      const SizedBox(height: 16),
                      // 密码输入框
                      CustomTextField(
                        controller: _passwordController,
                        labelText: '密码',
                        hintText: '请输入您的密码',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        validator: Validators.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 用户协议勾选框
                      // Consumer<AuthProvider>(
                      //   builder: (context, authProvider, child) {
                      //     return TermsCheckbox(
                      //       value: authProvider.isAgreedToTerms,
                      //       onChanged: authProvider.setAgreedToTerms,
                      //     );
                      //   },
                      // ),

                      const SizedBox(height: 32),

                      // 登录按钮
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 其他选项
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // 忘记密码逻辑
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('跳转到忘记密码页面')),
                              );
                            },
                            child: Text(
                              '忘记密码？',
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                          ),
                          Text(
                            ' | ',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          TextButton(
                            onPressed: () {
                              // 跳转注册页面
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()));
                            },
                            child: Text(
                              '立即注册',
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //登录请求
  Future<void> userLogin(String username, String password) async {
    final url = Uri.parse('http://127.0.0.1:80/runner/login.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);

        if (result['success'] == true) {
          //存储 user_id 和 token
          final token = result['token'];
          final userId = result['user_id'];

          final user = User(
            email: username,
            token: token,
            userId: userId,
          );

          DatabaseService().setUser(user);

          // 登录成功
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录成功，即将跳转到主页...')),
          );
          await Future.delayed(const Duration(seconds: 1));
          // 添加导航到主页的逻辑
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TabbarScreen()));
        } else {
          // 登录失败
          var msg = result['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登录失败：$msg')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录失败, 网络错误')),
        );
      }
    } on Exception catch (e) {
      print('登录失败-服务器错误：$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录失败, 服务器错误2')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
