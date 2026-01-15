import 'package:appexpflutter_update/features/punto_venta/domain/repositories/payment_info_repository.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_event.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/payment_info/payment_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentInfoBloc extends Bloc<PaymentInfoEvent, PaymentInfoState> {
  final PaymentInfoRepository repository;

  PaymentInfoBloc({required this.repository}) : super(PaymentInfoInitial()) {
    on<LoadPaymentInfoEvent>(_onLoadPaymentInfo);
  }

  Future<void> _onLoadPaymentInfo(
      LoadPaymentInfoEvent event, Emitter<PaymentInfoState> emit) async {
    emit(PaymentInfoLoading());
    try {
      final cuentas = await repository.getCuentas();
      final terminales = await repository.getTerminales();
      emit(PaymentInfoLoaded(cuentas: cuentas, terminales: terminales));
    } catch (e) {
      print('DEBUG: Error fetching payment info: $e');
      emit(PaymentInfoError(e.toString()));
    }
  }
}
