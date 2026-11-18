import 'package:uuid/uuid.dart';
import '../auth/jwt_service.dart';
import '../auth/password_service.dart';
import '../db/database.dart';
import '../db/queries/auth_queries.dart' as q;

class AuthResult {
  final TokenPair tokens;
  final Map<String, dynamic> user;

  const AuthResult({required this.tokens, required this.user});

  Map<String, dynamic> toJson() => {
        ...tokens.toJson(),
        'user': user,
      };
}

class AuthService {
  final Database _db;
  final PasswordService _passwords;
  final JwtService _jwt;
  final _uuid = const Uuid();

  AuthService(this._db, this._passwords, this._jwt);

  Future<AuthResult> register(
    String email,
    String password,
    String displayName,
  ) async {
    final existing = await q.findProfileByEmail(_db, email.toLowerCase());
    if (existing != null) {
      throw AuthException('An account with this email already exists');
    }

    final id = _uuid.v4();
    final hash = _passwords.hash(password);

    await _db.transaction((tx) async {
      await q.insertProfile(
        tx,
        id: id,
        email: email.toLowerCase(),
        passwordHash: hash,
        displayName: displayName,
      );
    });

    final tokens = _jwt.generateTokens(id, email: email.toLowerCase());
    return AuthResult(
      tokens: tokens,
      user: {
        'id': id,
        'email': email.toLowerCase(),
        'displayName': displayName,
      },
    );
  }

  Future<AuthResult> login(String email, String password) async {
    final profile = await q.findProfileByEmail(_db, email.toLowerCase());
    if (profile == null) {
      throw AuthException('Invalid email or password');
    }

    final hash = profile['password_hash'] as String;
    if (!_passwords.verify(password, hash)) {
      throw AuthException('Invalid email or password');
    }

    final id = profile['id'] as String;
    final tokens = _jwt.generateTokens(id, email: email.toLowerCase());
    return AuthResult(
      tokens: tokens,
      user: {
        'id': id,
        'email': profile['email'],
        'displayName': profile['display_name'],
        'avatarUrl': profile['avatar_url'],
      },
    );
  }

  Future<TokenPair> refreshTokens(String refreshToken) async {
    final payload = _jwt.verifyRefreshToken(refreshToken);
    if (payload == null) {
      throw AuthException('Invalid or expired refresh token');
    }

    final profile = await q.findProfileById(_db, payload.userId);
    if (profile == null) {
      throw AuthException('User not found');
    }

    return _jwt.generateTokens(
      payload.userId,
      email: profile['email'] as String?,
    );
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
