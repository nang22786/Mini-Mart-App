// lib/presentation/blocs/address/address_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/address/address_event.dart';
import 'package:mini_mart/bloc/address/address_state.dart';
import 'package:mini_mart/repositories/address/address_repository.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _addressRepository;

  AddressBloc(this._addressRepository) : super(AddressInitial()) {
    on<LoadAllAddresses>(_onLoadAllAddresses);
    on<LoadAddressesByUserId>(_onLoadAddressesByUserId);
    on<LoadAddressDetail>(_onLoadAddressDetail);
    on<CreateAddress>(_onCreateAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
  }

  // Load all addresses (for owner)
  Future<void> _onLoadAllAddresses(
    LoadAllAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _addressRepository.getAllAddresses();
      emit(AddressesLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  // Load addresses by user ID
  Future<void> _onLoadAddressesByUserId(
    LoadAddressesByUserId event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _addressRepository.getAddressesByUserId(
        event.userId,
      );
      emit(AddressesLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  // Load address detail
  Future<void> _onLoadAddressDetail(
    LoadAddressDetail event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _addressRepository.getAddressById(event.id);
      emit(AddressDetailLoaded(address));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  // Create address
  Future<void> _onCreateAddress(
    CreateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _addressRepository.createAddress(event.address);
      emit(AddressCreated(address));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  // Update address
  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _addressRepository.updateAddress(
        event.id,
        event.address,
      );
      emit(AddressUpdated(address));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  // Delete address
  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await _addressRepository.deleteAddress(event.id);
      emit(AddressDeleted());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
