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