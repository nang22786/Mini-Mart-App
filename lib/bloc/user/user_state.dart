import 'package:equatable/equatable.dart';
import 'package:mini_mart/model/user/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// Initial State
class UserInitial extends UserState {
  const UserInitial();
}

// Loading State
class UserLoading extends UserState {
  const UserLoading();
}

// User Info Loaded State
class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

// User Info Updated State
class UserUpdated extends UserState {
  final UserModel user;
  final String message;

  const UserUpdated({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

// Error State
class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
