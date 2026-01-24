import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:drawo_app/core/common/app_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drawo_app/data/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthService authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    // Watch for auth changes
    _userSubscription = _authRepository.onAuthStateChanged.listen((user) {
      if (user != null) {
        add(AuthStarted());
      } else {
        add(AuthSignOutRequested());
      }
    });
  }

  // Check if user is logged in on start
  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  // Handle login logic
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      AuthError error = AuthError.unknown;
      if (e.code == 'user-not-found') {
        error = AuthError.userNotFound;
      } else if (e.code == 'wrong-password') {
        error = AuthError.wrongPassword;
      } else if (e.code == 'invalid-email') {
        error = AuthError.invalidEmail;
      } else if (e.code == 'invalid-credential') {
        error = AuthError.invalidCredentials;
      }
      emit(state.copyWith(status: AuthStatus.error, error: error));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: AuthError.unknown));
    }
  }

  // Handle registration logic
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.register(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      AuthError error = AuthError.unknown;
      if (e.code == 'email-already-in-use') {
        error = AuthError.emailAlreadyInUse;
      } else if (e.code == 'weak-password') {
        error = AuthError.weakPassword;
      } else if (e.code == 'invalid-email') {
        error = AuthError.invalidEmail;
      }
      emit(state.copyWith(status: AuthStatus.error, error: error));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: AuthError.unknown));
    }
  }

  // Clear session and log out
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
