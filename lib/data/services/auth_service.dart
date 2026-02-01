import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Stream<User?> get onAuthStateChanged;
  User? get currentUser;
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class AuthService implements IAuthService {
  final FirebaseAuth _auth;
  AuthService({required FirebaseAuth auth}) : _auth = auth;

  // Listen for Firebase authentication state changes
  @override
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

  // Get currently logged in user
  @override
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password.trim(),
  );

  // Register new user with email and password
  @override
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  // Sign out currently logged in user
  @override
  Future<void> signOut() => _auth.signOut();
}
