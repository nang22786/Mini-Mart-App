import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/repositories/user/auth_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthRepository authRepository;

  UserBloc({required this.authRepository}) : super(const UserInitial()) {
    on<GetUserInfoEvent>(_onGetUserInfo);
    on<UpdateUserInfoEvent>(_onUpdateUserInfo);
    on<RefreshUserInfoEvent>(_onRefreshUserInfo);
  }

  // Get User Info Handler
  Future<void> _onGetUserInfo(
    GetUserInfoEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      print('📥 Fetching user info for ID: ${event.userId}');

      final user = await authRepository.getUserInfo(event.userId);

      print('✅ User info loaded: ${user.name}');
      emit(UserLoaded(user: user));
    } catch (e) {
      print('❌ Error loading user info: $e');
      emit(UserError(message: e.toString()));
    }
  }

  // Update User Info Handler
  Future<void> _onUpdateUserInfo(
    UpdateUserInfoEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      print('📝 Updating user info for ID: ${event.userId}');
      print('   Name: ${event.name}');
      print('   Phone: ${event.phone}');

      final updatedUser = await authRepository.updateUserInfo(
        userId: event.userId,
        userName: event.name,
        phone: event.phone,
        profileImage: event.profileImage,
      );

      print('✅ User info updated successfully');
      emit(
        UserUpdated(user: updatedUser, message: 'Profile updated successfully'),
      );

      // After showing success message, change to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      emit(UserLoaded(user: updatedUser));
    } catch (e) {
      print('❌ Error updating user info: $e');
      emit(UserError(message: e.toString()));
    }
  }

  // Refresh User Info Handler (for pull-to-refresh)
  Future<void> _onRefreshUserInfo(
    RefreshUserInfoEvent event,
    Emitter<UserState> emit,
  ) async {
    // Don't show loading indicator for refresh
    try {
      print('🔄 Refreshing user info for ID: ${event.userId}');

      final user = await authRepository.getUserInfo(event.userId);

      print('✅ User info refreshed');
      emit(UserLoaded(user: user));
    } catch (e) {
      print('❌ Error refreshing user info: $e');
      // Keep current state on refresh error
      if (state is UserLoaded) {
        emit(state);
      } else {
        emit(UserError(message: e.toString()));
      }
    }
  }
}
