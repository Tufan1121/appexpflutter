import 'package:equatable/equatable.dart';

class NetworkErrorModel extends Equatable {
  final int? statusCode;
  final String? statusMessage;

  const NetworkErrorModel({this.statusCode, this.statusMessage});

  factory NetworkErrorModel.fromJson(Map<String, dynamic> json) =>
      NetworkErrorModel(
        statusCode: json['status_code'] as int?,
        statusMessage: json['status_message'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status_message': statusMessage,
      };

  @override
  List<Object?> get props => [statusCode, statusMessage];
}
