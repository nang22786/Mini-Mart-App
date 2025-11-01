import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/user/user_model.dart';
import 'package:mini_mart/repositories/user/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<LoginEvent>(_onLogin);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  // Register Handler
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.register(
        email: event.email,
        password: event.password,
      );

      if (response.success) {
        emit(
          RegistrationSuccess(email: event.email, message: response.message),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.verifyOtp(
        email: event.email,
        code: event.code,
      );

      print('🔍 Response success: ${response.success}');
      print('🔍 User null: ${response.user == null}');
      print('🔍 Token null: ${response.accessToken == null}');

      if (response.success &&
          response.user != null &&
          response.accessToken != null) {
        print('✅ About to emit AuthAuthenticated');
        emit(
          AuthAuthenticated(
            user: response.user!,
            accessToken: response.accessToken!,
          ),
        );
        print('✅ AuthAuthenticated emitted');
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      print('❌ Exception in _onVerifyOtp: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  // Resend OTP Handler
  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.resendOtp(email: event.email);

      if (response.success) {
        emit(
          RegistrationSuccess(email: event.email, message: response.message),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Login Handler
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (response.success &&
          response.user != null &&
          response.accessToken != null) {
        emit(
          AuthAuthenticated(
            user: response.user!,
            accessToken: response.accessToken!,
          ),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Forgot Password Handler
  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.forgotPassword(email: event.email);

      if (response.success) {
        emit(OtpSent(email: event.email, message: response.message));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Reset Password Handler
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.resetPassword(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );

      if (response.success) {
        emit(PasswordResetSuccess(message: response.message));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Logout Handler
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Check Auth Status Handler (Auto-Login)
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = authRepository.isLoggedIn();

      if (isLoggedIn) {
        final userId = StorageService.getUserId();
        final email = StorageService.getUserEmail();
        final token = StorageService.getAccessToken();

        if (userId != null && email != null && token != null) {
          // User is logged in, restore session
          emit(
            AuthAuthenticated(
              user: UserModel(
                id: userId,
                name: email.split('@')[0], // Extract name from email
                email: email,
                role: 'customer',
                status: 'active',
                phoneNumber: '',
                image: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isActive: true,
              ),
              accessToken: token,
            ),
          );
        } else {
          // Incomplete data, logout
          await authRepository.logout();
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}
