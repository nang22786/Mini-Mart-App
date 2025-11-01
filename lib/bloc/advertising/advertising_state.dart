import 'package:equatable/equatable.dart';
import '../../model/advertising/advertising_model.dart';

abstract class AdvertisingState extends Equatable {
  const AdvertisingState();

  @override
  List<Object?> get props => [];
}

class AdvertisingInitial extends AdvertisingState {
  const AdvertisingInitial();
}

class AdvertisingLoading extends AdvertisingState {
  const AdvertisingLoading();
}

class AdvertisingLoaded extends AdvertisingState {
  final List<AdvertisingModel> advertising;

  const AdvertisingLoaded(this.advertising);

  @override
  List<Object?> get props => [advertising];
}

class AdvertisingDetailLoaded extends AdvertisingState {
  final AdvertisingModel advertising;

  const AdvertisingDetailLoaded(this.advertising);

  @override
  List<Object?> get props => [advertising];
}

// ✅ Now includes the advertising list
class AdvertisingOperationSuccess extends AdvertisingState {
  final String message;
  final List<AdvertisingModel> advertising;

  const AdvertisingOperationSuccess({
    required this.message,
    required this.advertising,
  });

  @override
  List<Object> get props => [
    message,
    advertising,
    DateTime.now().millisecondsSinceEpoch,
  ];
}

class AdvertisingError extends AdvertisingState {
  final String message;

  const AdvertisingError(this.message);

  @override
  List<Object?> get props => [message];
}
