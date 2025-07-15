import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runner_sync_app/screens/login_screen.dart';
import 'package:runner_sync_app/screens/register_screen.dart';
import 'package:runner_sync_app/widgets/custom_text_field.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display all login form elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 验证标题
      expect(find.text('用户登录'), findsOneWidget);

      // 验证邮箱输入框的提示文本
      expect(find.text('请输入您的邮箱地址'), findsOneWidget);

      // 验证密码输入框的提示文本
      expect(find.text('请输入您的密码'), findsOneWidget);

      // 验证登录按钮
      expect(find.widgetWithText(ElevatedButton, '登录'), findsOneWidget);

      // 验证忘记密码链接
      expect(find.text('忘记密码？'), findsOneWidget);

      // 验证注册链接
      expect(find.text('立即注册'), findsOneWidget);

      // 验证图标
      expect(find.byIcon(Icons.account_circle), findsOneWidget);

      // 验证邮箱和密码图标
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 查找密码可见性切换按钮
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);

      // 点击切换按钮
      await tester.tap(visibilityButton);
      await tester.pump();

      // 验证图标变为 visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // 再次点击切换回来
      final visibilityOffButton = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityOffButton);
      await tester.pump();

      // 验证图标变回 visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets(
        'should navigate to register screen when register button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/register': (context) => const RegisterScreen(),
          },
        ),
      );

      // 查找并点击注册按钮
      final registerButton = find.text('立即注册');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // 验证导航到注册页面
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('should show snackbar when forgot password is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 查找并点击忘记密码按钮
      final forgotPasswordButton = find.text('忘记密码？');
      await tester.tap(forgotPasswordButton);
      await tester.pump();

      // 验证显示 SnackBar
      expect(find.text('跳转到忘记密码页面'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
        'should show loading indicator when form is submitted with valid data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 查找输入框
      final emailField = find.byType(CustomTextField).first;
      final passwordField = find.byType(CustomTextField).last;

      // 输入有效的邮箱和密码
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // 点击登录按钮
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证显示加载指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not submit form when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 直接点击登录按钮而不输入任何内容
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证没有显示加载指示器（因为表单验证失败）
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should maintain input values after state changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 输入文本
      final emailField = find.byType(CustomTextField).first;
      await tester.enterText(emailField, 'test@example.com');

      // 触发状态变化（切换密码可见性）
      final visibilityButton = find.byIcon(Icons.visibility);
      await tester.tap(visibilityButton);
      await tester.pump();

      // 验证输入的文本仍然存在
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });

  group('LoginScreen Form Validation Tests', () {
    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 输入无效的邮箱格式
      final emailField = find.byType(CustomTextField).first;
      await tester.enterText(emailField, 'invalid-email');

      // 点击登录按钮触发验证
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证没有显示加载指示器（因为验证失败）
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 输入有效邮箱但留空密码
      final emailField = find.byType(CustomTextField).first;
      await tester.enterText(emailField, 'test@example.com');

      // 点击登录按钮触发验证
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证没有显示加载指示器（因为密码验证失败）
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should accept valid email and password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 输入有效的邮箱和密码
      final emailField = find.byType(CustomTextField).first;
      final passwordField = find.byType(CustomTextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // 点击登录按钮
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证显示加载指示器（表示验证通过）
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoginScreen UI State Tests', () {
    testWidgets('should disable login button when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 输入有效数据
      final emailField = find.byType(CustomTextField).first;
      final passwordField = find.byType(CustomTextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // 点击登录按钮
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证按钮被禁用（通过查找 CircularProgressIndicator）
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 验证按钮文本消失
      expect(find.widgetWithText(ElevatedButton, '登录'), findsNothing);
    });

    testWidgets('should show proper button styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 查找登录按钮
      final loginButton = find.widgetWithText(ElevatedButton, '登录');
      expect(loginButton, findsOneWidget);

      // 获取按钮组件
      final elevatedButton = tester.widget<ElevatedButton>(loginButton);

      // 验证按钮样式
      expect(elevatedButton.style?.backgroundColor?.resolve({}),
          equals(Colors.blue[600]));
      expect(elevatedButton.style?.foregroundColor?.resolve({}),
          equals(Colors.white));
    });

    testWidgets('should have proper text field styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 验证存在两个 CustomTextField
      expect(find.byType(CustomTextField), findsNWidgets(2));

      // 验证图标存在
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('LoginScreen Navigation Tests', () {
    testWidgets('should have proper navigation structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 验证页面基本结构
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should handle back navigation properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      // 验证 LoginScreen 存在
      expect(find.byType(LoginScreen), findsOneWidget);

      // 模拟返回操作
      await tester.pageBack();
      await tester.pump();

      // 验证没有崩溃
      expect(tester.takeException(), isNull);
    });
  });
}
