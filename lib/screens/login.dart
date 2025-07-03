import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码长度不能少于6位';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAgreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请先同意用户协议'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    userLogin(_emailController.text, _passwordController.text);

    // 这里可以添加导航到主页的逻辑
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo 或标题
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue[600],
                ),
                SizedBox(height: 32),

                Text(
                  '用户登录',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 48),

                // 登录表单
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 邮箱输入框
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          labelText: '邮箱地址',
                          hintText: '请输入您的邮箱地址',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // 密码输入框
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          labelText: '密码',
                          hintText: '请输入您的密码',
                          prefixIcon: Icon(Icons.lock_outline),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // 用户协议勾选框
                      Row(
                        children: [
                          Checkbox(
                            value: _isAgreedToTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _isAgreedToTerms = value ?? false;
                              });
                            },
                            activeColor: Colors.blue[600],
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAgreedToTerms = !_isAgreedToTerms;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '我已阅读并同意',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    TextSpan(
                                      text: '《用户协议》',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '和',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    TextSpan(
                                      text: '《隐私政策》',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

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
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  '登录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // 其他选项
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // 忘记密码逻辑
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('跳转到忘记密码页面')),
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
                              // 注册逻辑
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('跳转到注册页面')),
                              );
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
        // 登录成功
        print('登录成功...');
      } else {
        // 登录失败
        print('登录失败：${result['msg']}');
      }
    } else {
      print('服务器错误：HTTP ${response.body}， code: ${response.statusCode}');
    }
  }
}
