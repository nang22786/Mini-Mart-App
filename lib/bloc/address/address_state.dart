// lib/presentation/blocs/address/address_state.dart

import 'package:equatable/equatable.dart';
import 'package:mini_mart/model/address/address_model.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AddressInitial extends AddressState {}

// Loading state
class AddressLoading extends AddressState {}

// Addresses loaded successfully
class AddressesLoaded extends AddressState {
  final List<AddressModel> addresses;

  const AddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

// Address detail loaded
class AddressDetailLoaded extends AddressState {
  final AddressModel address;

  const AddressDetailLoaded(this.address);

  @override
  List<Object?> get props => [address];
}

// Address created successfully
class AddressCreated extends AddressState {
  final AddressModel address;

  const AddressCreated(this.address);

  @override
  List<Object?> get props => [address];
}

// Address updated successfully
class AddressUpdated extends AddressState {
  final AddressModel address;

  const AddressUpdated(this.address);

  @override
  List<Object?> get props => [address];
}

// Address deleted successfully
class AddressDeleted extends AddressState {}

// Error state
class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
