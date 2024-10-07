import 'package:punto_venta/domain/entities/tickets_entity.dart';
import 'package:punto_venta/domain/usecases/tickets_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'consulta_event.dart';
part 'consulta_state.dart';

class ConsultaBloc extends Bloc<ConsultaEvent, ConsultaState> {
  final TicketsUsecase ticketsUsecase;
  ConsultaBloc({required this.ticketsUsecase}) : super(ConsultaInitial()) {
    on<GetSalesTicketsEvent>(_getSalesTickets);
    on<ClearTicketsEvent>(
        (event, emit) => _clearProductsIBodegaState(emit));
  }

  Future<void> _getSalesTickets(
      GetSalesTicketsEvent event, Emitter<ConsultaState> emit) async {
    emit(ConsultaLoading());
    final result =
        await ticketsUsecase.getTickets(event.fechaInicio, event.fechaFin);
    result.fold(
      (error) => emit(ConsultaError(message: error.message)),
      (tickets) => emit(ConsultaLoaded(tickets: tickets)),
    );
  }

  void _clearProductsIBodegaState(Emitter<ConsultaState> emit) {
    emit(ConsultaInitial());
  }

}
