part of 'auth_bloc.dart';

enum AuthStatus { initial, authenticated, unauthenticated, error, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final AuthError error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error = AuthError.none,
  });

  @override
  List<Object?> get props => [status, user, error];

  AuthState copyWith({AuthStatus? status, User? user, AuthError? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
