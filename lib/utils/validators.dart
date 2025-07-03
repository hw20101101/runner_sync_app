class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }

    // final emailRegex =
    //     RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    // if (!emailRegex.hasMatch(value)) {
    //   return '请输入有效的邮箱地址';
    // }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码长度不能少于6位';
    }

    return null;
  }
}
