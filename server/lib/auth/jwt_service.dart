import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/env.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

class JwtPayload {
  final String userId;
  final String? email;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const JwtPayload({
    required this.userId,
    this.email,
    required this.issuedAt,
    required this.expiresAt,
  });
}

class JwtService {
  final String _secret;
  final int _accessExpiryMinutes;
  final int _refreshExpiryDays;

  JwtService(Env env)
      : _secret = env.jwtSecret,
        _accessExpiryMinutes = env.jwtAccessExpiryMinutes,
        _refreshExpiryDays = env.jwtRefreshExpiryDays;

  TokenPair generateTokens(String userId, {String? email}) {
    final accessJwt = JWT({
      'sub': userId,
      if (email != null) 'email': email,
      'type': 'access',
    });

    final refreshJwt = JWT({
      'sub': userId,
      'type': 'refresh',
    });

    final accessToken = accessJwt.sign(
      SecretKey(_secret),
      expiresIn: Duration(minutes: _accessExpiryMinutes),
    );

    final refreshToken = refreshJwt.sign(
      SecretKey(_secret),
      expiresIn: Duration(days: _refreshExpiryDays),
    );

    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  JwtPayload? verifyAccessToken(String token) {
    return _verify(token, expectedType: 'access');
  }

  JwtPayload? verifyRefreshToken(String token) {
    return _verify(token, expectedType: 'refresh');
  }

  JwtPayload? _verify(String token, {required String expectedType}) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      final payload = jwt.payload as Map<String, dynamic>;

      if (payload['type'] != expectedType) return null;

      final sub = payload['sub'] as String?;
      if (sub == null) return null;

      final iat = payload['iat'] as num?;
      final exp = payload['exp'] as num?;

      return JwtPayload(
        userId: sub,
        email: payload['email'] as String?,
        issuedAt: iat != null
            ? DateTime.fromMillisecondsSinceEpoch((iat * 1000).toInt())
            : DateTime.now(),
        expiresAt: exp != null
            ? DateTime.fromMillisecondsSinceEpoch((exp * 1000).toInt())
            : DateTime.now(),
      );
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }
}
