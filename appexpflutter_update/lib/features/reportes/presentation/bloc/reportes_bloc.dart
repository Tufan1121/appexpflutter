import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/usecases/sales_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reportes_event.dart';
part 'reportes_state.dart';

class ReportesBloc extends Bloc<ReportesEvent, ReportesState> {
  final SalesUsecase salesUsecase;
  ReportesBloc({required this.salesUsecase}) : super(ReportesInitial()) {
    on<GetReportesPedidosEvent>(_getReportesPedidosEvent);
    on<GetReportesTicketsEvent>(_getReportesTicketsEvent);
    on<AuthMovilEvent>(_authMovilEvent);
  }
  List<SalesPedidosEntity> _pedidos = [];
  List<SalesTicketsEntity> _tickets = [];

  Future<void> _getReportesPedidosEvent(
      GetReportesPedidosEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesPedidos();
    result.fold(
      (failure) => emit(ReportesError(message: failure.message)),
      (salesPedidos) {
        _pedidos = salesPedidos;
        emit(ReportesLoaded(salesPedidos: _pedidos, salesTickets: _tickets));
      },
    );
  }

  Future<void> _getReportesTicketsEvent(
      GetReportesTicketsEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesTickets();
    result.fold((failure) => emit(ReportesError(message: failure.message)),
        (salesTickets) {
      _tickets = salesTickets;
      emit(ReportesLoaded(salesPedidos: _pedidos, salesTickets: _tickets));
    });
  }

  Future<void> _authMovilEvent(
      AuthMovilEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final prefs = await SharedPreferences.getInstance();
    final movil = prefs.getString('movil') ?? '';
    if (event.movil == movil) {
      emit(const AuthMovil(isAuthMovil: true));
    } else {
      emit(const AuthMovil(isAuthMovil: false));
    }
  }
}
