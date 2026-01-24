import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Stream<User?> get onAuthStateChanged;
  User? get currentUser;
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });
  Future<UserCredential> register({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class AuthService implements IAuthService {
  final FirebaseAuth _auth;
  AuthService({required FirebaseAuth auth}) : _auth = auth;

  @override
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password.trim(),
  );

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(
    email: email.trim(),
    password: password.trim(),
  );

  @override
  Future<void> signOut() => _auth.signOut();
}
