import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Register Event
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;

  const RegisterEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// Verify OTP Event
class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyOtpEvent({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

// Resend OTP Event
class ResendOtpEvent extends AuthEvent {
  final String email;

  const ResendOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

// Login Event
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// Forgot Password Event
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

// Reset Password Event
class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

// Logout Event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// Check Auth Status Event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
