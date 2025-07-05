import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:runner_sync_app/utils/validators.dart';
import 'package:runner_sync_app/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    registerUser(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('注册账号',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              // 返回登录页面
              Navigator.pop(context);
            },
          )),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      // 验证码输入框
                      CustomTextField(
                        controller: _passwordController,
                        labelText: '验证码',
                        hintText: '请输入收到的验证码',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        validator: Validators.validatePassword,
                        suffixIcon: IconButton(
                          //验证码图标 - 待完善 ToDo 0705
                          icon: const Icon(Icons.info_outline,
                              color: Colors.orange),
                          onPressed: () {
                            // setState(() {
                            //   _isPasswordVisible = !_isPasswordVisible;
                            // });
                          },
                        ),
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

                      const SizedBox(height: 32),

                      // 登录按钮
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                                  '注册',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
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

  //注册请求
  Future<void> registerUser(String username, String password) async {
    final url = Uri.parse('http://127.0.0.1:80/runner/register.php');

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
        // print('恭喜，用户注册成功...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('恭喜，用户注册成功...')),
        );
        await Future.delayed(const Duration(seconds: 1));
        // 返回登录页面
        Navigator.pop(context);
      } else {
        var msg = result['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册失败：$msg')),
        );
      }
    } else {
      print('注册-服务器错误：HTTP ${response.body}， code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册失败, 请稍后再试...')),
      );
    }
  }
}
