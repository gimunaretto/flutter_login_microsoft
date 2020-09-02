// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoginUpload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginUpload _$LoginUploadFromJson(Map<String, dynamic> json) {
  return LoginUpload(
    login: json['login'] as String,
    senha: json['senha'] as String,
  );
}

Map<String, dynamic> _$LoginUploadToJson(LoginUpload instance) =>
    <String, dynamic>{
      'login': instance.login,
      'senha': instance.senha,
    };
