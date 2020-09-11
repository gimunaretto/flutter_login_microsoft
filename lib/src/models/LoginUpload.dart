import 'package:json_annotation/json_annotation.dart';
part 'LoginUpload.g.dart';

@JsonSerializable()
class LoginUpload {
  LoginUpload({this.login, this.senha});

  factory LoginUpload.fromJson(Map<String, dynamic> json) =>
      _$LoginUploadFromJson(json);

  String login;
  String senha;

  Map<String, dynamic> toJson() => _$LoginUploadToJson(this);
}

@JsonSerializable()
class User {
  String usuario;
  String senha;

  User.fromJson(Map<String, dynamic> json)
      : usuario = json['Usuario'],
        senha = json['Senha'];

  Map<String, dynamic> toJson() => {
        'Usuario': usuario,
        'Senha': senha,
      };
}
