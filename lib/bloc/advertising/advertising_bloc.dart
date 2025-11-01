import 'package:flutter_bloc/flutter_bloc.dart';
import 'advertising_event.dart';
import 'advertising_state.dart';
import '../../repositories/advertising/advertising_repository.dart';

class AdvertisingBloc extends Bloc<AdvertisingEvent, AdvertisingState> {
  final AdvertisingRepository _repository;

  AdvertisingBloc(this._repository) : super(AdvertisingInitial()) {
    on<LoadAdvertising>(_onLoadAdvertising);
    on<LoadAdvertisingById>(_onLoadAdvertisingById);
    on<CreateAdvertising>(_onCreateAdvertising);
    on<UpdateAdvertising>(_onUpdateAdvertising);
    on<ToggleActiveStatus>(_onToggleActiveStatus);
    on<DeleteAdvertising>(_onDeleteAdvertising);
  }

  Future<void> _onLoadAdvertising(
    LoadAdvertising event,
    Emitter<AdvertisingState> emit,
  ) async {
    emit(AdvertisingLoading());
    try {
      final advertising = await _repository.getAllAdvertising();
      emit(AdvertisingLoaded(advertising));
    } catch (e) {
      emit(AdvertisingError(e.toString()));
    }
  }

  Future<void> _onLoadAdvertisingById(
    LoadAdvertisingById event,
    Emitter<AdvertisingState> emit,
  ) async {
    emit(AdvertisingLoading());
    try {
      final advertising = await _repository.getAdvertisingById(event.id);
      emit(AdvertisingDetailLoaded(advertising));
    } catch (e) {
      emit(AdvertisingError(e.toString()));
    }
  }

  Future<void> _onCreateAdvertising(
    CreateAdvertising event,
    Emitter<AdvertisingState> emit,
  ) async {
    emit(AdvertisingLoading());
    try {
      await _repository.createAdvertising(
        imagePath: event.imagePath,
        isActive: event.isActive,
      );

      final advertising = await _repository.getAllAdvertising();
      // Emit with both data and message
      emit(
        AdvertisingOperationSuccess(
          message: 'Advertisement created successfully',
          advertising: advertising,
        ),
      );
    } catch (e) {
      emit(AdvertisingError(e.toString()));
      // Try to reload data even after error
      try {
        final advertising = await _repository.getAllAdvertising();
        emit(AdvertisingLoaded(advertising));
      } catch (_) {}
    }
  }

  Future<void> _onUpdateAdvertising(
    UpdateAdvertising event,
    Emitter<AdvertisingState> emit,
  ) async {
    emit(AdvertisingLoading());
    try {
      await _repository.updateAdvertising(
        id: event.id,
        imagePath: event.imagePath,
        isActive: event.isActive,
      );

      final advertising = await _repository.getAllAdvertising();
      // Emit with both data and message
      emit(
        AdvertisingOperationSuccess(
          message: 'Advertisement updated successfully',
          advertising: advertising,
        ),
      );
    } catch (e) {
      emit(AdvertisingError(e.toString()));
      // Try to reload data even after error
      try {
        final advertising = await _repository.getAllAdvertising();
        emit(AdvertisingLoaded(advertising));
      } catch (_) {}
    }
  }

  Future<void> _onToggleActiveStatus(
    ToggleActiveStatus event,
    Emitter<AdvertisingState> emit,
  ) async {
    try {
      await _repository.toggleActiveStatus(
        id: event.id,
        isActive: event.isActive,
      );

      final advertising = await _repository.getAllAdvertising();
      // Only emit loaded state - no success message for silent toggle
      emit(AdvertisingLoaded(advertising));
    } catch (e) {
      emit(AdvertisingError(e.toString()));
      // Try to reload data to revert UI
      try {
        final advertising = await _repository.getAllAdvertising();
        emit(AdvertisingLoaded(advertising));
      } catch (_) {}
    }
  }

  Future<void> _onDeleteAdvertising(
    DeleteAdvertising event,
    Emitter<AdvertisingState> emit,
  ) async {
    emit(AdvertisingLoading());
    try {
      await _repository.deleteAdvertising(event.id);

      final advertising = await _repository.getAllAdvertising();
      // Emit with both data and message
      emit(
        AdvertisingOperationSuccess(
          message: 'Advertisement deleted successfully',
          advertising: advertising,
        ),
      );
    } catch (e) {
      emit(AdvertisingError(e.toString()));
      // Try to reload data even after error
      try {
        final advertising = await _repository.getAllAdvertising();
        emit(AdvertisingLoaded(advertising));
      } catch (_) {}
    }
  }
}
