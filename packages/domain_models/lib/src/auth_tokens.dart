import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({
    required AuthTokens tokens,
    required User user,
  }) = _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);
}
