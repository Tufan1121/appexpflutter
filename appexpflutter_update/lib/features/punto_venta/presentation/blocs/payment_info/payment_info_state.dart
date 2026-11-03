import 'package:appexpflutter_update/features/punto_venta/data/models/cuenta_model.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/terminal_model.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentInfoState extends Equatable {
  const PaymentInfoState();
  
  @override
  List<Object> get props => [];
}

class PaymentInfoInitial extends PaymentInfoState {}

class PaymentInfoLoading extends PaymentInfoState {}

class PaymentInfoLoaded extends PaymentInfoState {
  final List<CuentaModel> cuentas;
  final List<TerminalModel> terminales;

  const PaymentInfoLoaded({required this.cuentas, required this.terminales});

  @override
  List<Object> get props => [cuentas, terminales];
}

class PaymentInfoError extends PaymentInfoState {
  final String message;

  const PaymentInfoError(this.message);

  @override
  List<Object> get props => [message];
}
