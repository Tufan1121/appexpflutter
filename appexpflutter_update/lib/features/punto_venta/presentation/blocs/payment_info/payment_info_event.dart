import 'package:equatable/equatable.dart';

abstract class PaymentInfoEvent extends Equatable {
  const PaymentInfoEvent();

  @override
  List<Object> get props => [];
}

class LoadPaymentInfoEvent extends PaymentInfoEvent {}
