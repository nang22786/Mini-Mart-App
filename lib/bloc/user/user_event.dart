import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

// Get User Info Event
class GetUserInfoEvent extends UserEvent {
  final int userId;

  const GetUserInfoEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Update User Info Event
class UpdateUserInfoEvent extends UserEvent {
  final int userId;
  final String? name;
  final String? phone;
  final String? profileImage;

  const UpdateUserInfoEvent({
    required this.userId,
    this.name,
    this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [userId, name, phone, profileImage];
}

// Refresh User Info Event (for pull-to-refresh)
class RefreshUserInfoEvent extends UserEvent {
  final int userId;

  const RefreshUserInfoEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
