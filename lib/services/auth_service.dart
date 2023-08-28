import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/common/auth_exception_handler.dart';
import 'package:untitled/common/auth_status.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  AuthStatus _status = AuthStatus.successful;
//...

  Future<AuthStatus> createAccount(
      {required String email,
      required String password,
      required String? displayName,
      required String? phone}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _auth.currentUser!.updateDisplayName(displayName);
      _status = AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }

  Future<AuthStatus> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError(
            (e) => _status = AuthExceptionHandler.handleAuthException(e));
    return _status;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
