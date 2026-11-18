// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };

_AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => _AuthResult(
  tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResultToJson(_AuthResult instance) =>
    <String, dynamic>{'tokens': instance.tokens, 'user': instance.user};
