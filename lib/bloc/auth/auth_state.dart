import 'package:equatable/equatable.dart';
import 'package:mini_mart/model/user/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial State
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading State
class AuthLoading extends AuthState {
  const AuthLoading();
}

// Authenticated State (Logged In)
class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String accessToken;

  const AuthAuthenticated({required this.user, required this.accessToken});

  @override
  List<Object?> get props => [user, accessToken];
}

// Unauthenticated State (Not Logged In)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Registration Success (Need OTP Verification)
class RegistrationSuccess extends AuthState {
  final String email;
  final String message;

  const RegistrationSuccess({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// OTP Sent (For Forgot Password)
class OtpSent extends AuthState {
  final String email;
  final String message;

  const OtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// Password Reset Success
class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// Error State
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
