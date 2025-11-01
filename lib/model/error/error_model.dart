import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  final String message;
  final int? statusCode;
  final String? error;

  const ErrorModel({required this.message, this.statusCode, this.error});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      error: json['error'],
    );
  }

  @override
  List<Object?> get props => [message, statusCode, error];

  @override
  String toString() => message;
}
