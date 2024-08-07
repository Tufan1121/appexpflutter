import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/usecases/sales_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'reportes_event.dart';
part 'reportes_state.dart';

class ReportesBloc extends Bloc<ReportesEvent, ReportesState> {
  final SalesUsecase salesUsecase;
  ReportesBloc({required this.salesUsecase}) : super(ReportesInitial()) {
    on<GetReportesPedidosEvent>(_getReportesPedidosEvent);
    on<GetReportesTicketsEvent>(_getReportesTicketsEvent);
  }

  Future<void> _getReportesPedidosEvent(
      GetReportesPedidosEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesPedidos();
    result.fold(
      (failure) => emit(ReportesError(message: failure.message)),
      (salesPedidos) {
        add(GetReportesTicketsEvent(salesPedidos: salesPedidos));
      },
    );
  }

  Future<void> _getReportesTicketsEvent(
      GetReportesTicketsEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesTickets();
    result.fold((failure) => emit(ReportesError(message: failure.message)),
        (salesPedidos) {
      emit(ReportesLoaded(
          salesPedidos: event.salesPedidos, salesTickets: salesPedidos));
    });
  }
}
