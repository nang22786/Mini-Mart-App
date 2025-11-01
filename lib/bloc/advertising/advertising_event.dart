import 'package:equatable/equatable.dart';

abstract class AdvertisingEvent extends Equatable {
  const AdvertisingEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdvertising extends AdvertisingEvent {
  const LoadAdvertising();
}

class LoadAdvertisingById extends AdvertisingEvent {
  final int id;

  const LoadAdvertisingById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateAdvertising extends AdvertisingEvent {
  final String imagePath;
  final bool isActive;

  const CreateAdvertising({required this.imagePath, this.isActive = true});

  @override
  List<Object?> get props => [imagePath, isActive];
}

class UpdateAdvertising extends AdvertisingEvent {
  final int id;
  final String imagePath;
  final bool? isActive;

  const UpdateAdvertising({
    required this.id,
    required this.imagePath,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, imagePath, isActive];
}

class ToggleActiveStatus extends AdvertisingEvent {
  final int id;
  final bool isActive;

  const ToggleActiveStatus({required this.id, required this.isActive});

  @override
  List<Object?> get props => [id, isActive];
}

class DeleteAdvertising extends AdvertisingEvent {
  final int id;

  const DeleteAdvertising(this.id);

  @override
  List<Object?> get props => [id];
}
