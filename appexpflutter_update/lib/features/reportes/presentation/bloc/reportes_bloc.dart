import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
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
    on<GetReportesVendedorEvent>(_getReportesVendedorEvent);
    on<GetReportesMetaEvent>(_getReportesMetaEvent);
    on<AuthMovilEvent>(_authMovilEvent);
  }
  List<SalesPedidosEntity> _pedidos = [];
  List<SalesTicketsEntity> _tickets = [];
  List<SalesVendedorEntity> _vendedores = [];
  MetaExpoEntity? _metaExpo;

  Future<void> _getReportesPedidosEvent(
      GetReportesPedidosEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesPedidos(
        fechaini: event.fechaini, fechafin: event.fechafin);
    result.fold(
      (failure) => emit(ReportesError(message: failure.message)),
      (salesPedidos) {
        _pedidos = salesPedidos;
        emit(ReportesLoaded(
            salesPedidos: _pedidos,
            salesTickets: _tickets,
            salesVendedor: _vendedores,
            metaExpo: _metaExpo));
      },
    );
  }

  Future<void> _getReportesTicketsEvent(
      GetReportesTicketsEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesTickets(
        fechaini: event.fechaini, fechafin: event.fechafin);
    result.fold((failure) => emit(ReportesError(message: failure.message)),
        (salesTickets) {
      _tickets = salesTickets;
      emit(ReportesLoaded(
          salesPedidos: _pedidos,
          salesTickets: _tickets,
          salesVendedor: _vendedores,
          metaExpo: _metaExpo));
    });
  }

  Future<void> _getReportesVendedorEvent(
      GetReportesVendedorEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getSalesByVendedor(
        fechaini: event.fechaini, fechafin: event.fechafin);
    result.fold((failure) => emit(ReportesError(message: failure.message)),
        (salesVendedor) {
      _vendedores = salesVendedor;
      emit(ReportesLoaded(
          salesPedidos: _pedidos,
          salesTickets: _tickets,
          salesVendedor: _vendedores,
          metaExpo: _metaExpo));
    });
  }

  Future<void> _getReportesMetaEvent(
      GetReportesMetaEvent event, Emitter<ReportesState> emit) async {
    emit(ReportesLoading());
    final result = await salesUsecase.getMetaExpo();
    result.fold((failure) => emit(ReportesError(message: failure.message)),
        (metaExpo) {
      _metaExpo = metaExpo;
      emit(ReportesLoaded(
          salesPedidos: _pedidos,
          salesTickets: _tickets,
          salesVendedor: _vendedores,
          metaExpo: _metaExpo));
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
