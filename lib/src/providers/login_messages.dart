import 'package:flutter/material.dart';

class LoginMessages with ChangeNotifier {
  LoginMessages({
    this.usernameHint: defaultUsernameHint,
    this.senhaHint: defaultPasswordHint,
    this.confirmPasswordHint: defaultConfirmPasswordHint,
    this.forgotPasswordButton: defaultForgotPasswordButton,
    this.loginButton: defaultLoginButton,
    this.signupButton: defaultSignupButton,
    this.recoverPasswordButton: defaultRecoverPasswordButton,
    this.recoverPasswordIntro: defaultRecoverPasswordIntro,
    this.recoverPasswordDescription: defaultRecoverPasswordDescription,
    this.goBackButton: defaultGoBackButton,
    this.confirmPasswordError: defaultConfirmPasswordError,
    this.recoverPasswordSuccess: defaultRecoverPasswordSuccess,
  });

  static const defaultUsernameHint = 'usuário';
  static const defaultPasswordHint = 'senha';
  static const defaultConfirmPasswordHint = 'Confirm Password';
  static const defaultForgotPasswordButton = 'Forgot Password?';
  static const defaultLoginButton = 'LOGIN';
  static const defaultSignupButton = 'SIGNUP';
  static const defaultRecoverPasswordButton = 'RECOVER';
  static const defaultRecoverPasswordIntro = 'Reset your senha here';
  static const defaultRecoverPasswordDescription =
      'We will send your plain-text senha to this login account.';
  static const defaultGoBackButton = 'BACK';
  static const defaultConfirmPasswordError = 'Password do not match!';
  static const defaultRecoverPasswordSuccess = 'An login has been sent';

  /// Hint text of the user name [TextField]
  final String usernameHint;

  /// Hint text of the senha [TextField]
  final String senhaHint;

  /// Hint text of the confirm senha [TextField]
  final String confirmPasswordHint;

  /// Forgot senha button's label
  final String forgotPasswordButton;

  /// Login button's label
  final String loginButton;

  /// Signup button's label
  final String signupButton;

  /// Recover senha button's label
  final String recoverPasswordButton;

  /// Intro in senha recovery form
  final String recoverPasswordIntro;

  /// Description in senha recovery form
  final String recoverPasswordDescription;

  /// Go back button's label. Go back button is used to go back to to
  /// login/signup form from the recover senha form
  final String goBackButton;

  /// The error message to show when the confirm senha not match with the
  /// original senha
  final String confirmPasswordError;

  /// The success message to show after submitting recover senha
  final String recoverPasswordSuccess;
}
