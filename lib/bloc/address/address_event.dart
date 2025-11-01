// lib/presentation/blocs/address/address_event.dart

import 'package:equatable/equatable.dart';
import 'package:mini_mart/model/address/address_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

// Load all addresses (for owner)
class LoadAllAddresses extends AddressEvent {}

// Load addresses by user ID
class LoadAddressesByUserId extends AddressEvent {
  final int userId;

  const LoadAddressesByUserId(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Load address detail
class LoadAddressDetail extends AddressEvent {
  final int id;

  const LoadAddressDetail(this.id);

  @override
  List<Object?> get props => [id];
}

// Create address
class CreateAddress extends AddressEvent {
  final AddressModel address;

  const CreateAddress(this.address);

  @override
  List<Object?> get props => [address];
}

// Update address
class UpdateAddress extends AddressEvent {
  final int id;
  final AddressModel address;

  const UpdateAddress(this.id, this.address);

  @override
  List<Object?> get props => [id, address];
}

// Delete address
class DeleteAddress extends AddressEvent {
  final int id;

  const DeleteAddress(this.id);

  @override
  List<Object?> get props => [id];
}
