import 'package:flutter/material.dart';

import '../models/LoginUpload.dart';

enum AuthMode { Signup, Login }

/// The result is an error message, callback successes if message is null
typedef AuthCallback = Future<String> Function(LoginUpload);

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String> Function(String);

class Auth with ChangeNotifier {
  Auth({
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    String login = '',
    String senha = '',
    String confirmPassword = '',
  })  : this._login = login,
        this._senha = senha,
        this._confirmPassword = confirmPassword;

  final AuthCallback onLogin;
  final AuthCallback onSignup;
  final RecoverCallback onRecoverPassword;

  AuthMode _mode = AuthMode.Login;

  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  bool get isLogin => _mode == AuthMode.Login;
  bool get isSignup => _mode == AuthMode.Signup;
  bool isRecover = false;

  AuthMode opposite() {
    return _mode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.Login) {
      mode = AuthMode.Signup;
    } else if (mode == AuthMode.Signup) {
      mode = AuthMode.Login;
    }
    return mode;
  }

  String _login = '';
  get login => _login;
  set login(String login) {
    _login = login;
    notifyListeners();
  }

  String _senha = '';
  get senha => _senha;
  set senha(String senha) {
    _senha = senha;
    notifyListeners();
  }

  String _confirmPassword = '';
  get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }
}
