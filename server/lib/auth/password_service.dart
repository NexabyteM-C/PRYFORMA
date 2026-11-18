import 'package:dbcrypt/dbcrypt.dart';

class PasswordService {
  final _crypt = DBCrypt();

  String hash(String password) {
    final salt = _crypt.gensaltWithRounds(12);
    return _crypt.hashpw(password, salt);
  }

  bool verify(String password, String hashedPassword) {
    try {
      return _crypt.checkpw(password, hashedPassword);
    } catch (_) {
      return false;
    }
  }
}
