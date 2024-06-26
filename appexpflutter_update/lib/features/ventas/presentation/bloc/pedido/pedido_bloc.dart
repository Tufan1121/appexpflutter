import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/pedido_usecase.dart';

part 'pedido_event.dart';
part 'pedido_state.dart';

class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  final PedidoUsecase pedidoUsecase;
  PedidoBloc({required this.pedidoUsecase}) : super(PedidoInitial()) {
    on<PedidoAddEvent>(_pedidoAddEvent);
    on<PedidoAddDetalleEvent>(_pedidoAddDetalleEvent);
    on<ClearPedidoStateEvent>((event, emit) => _clearPedidoState(emit));
  }

  Future<void> _pedidoAddEvent(
      PedidoAddEvent event, Emitter<PedidoState> emit) async {
    final result = await pedidoUsecase.addPedido(event.data);
    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (idPedido) {
        add(PedidoAddDetalleEvent(
            idPedido: idPedido, products: event.products));
        emit(PedidoLoaded(idPedido: idPedido));
      },
    );
  }

  Future<void> _pedidoAddDetalleEvent(
      PedidoAddDetalleEvent event, Emitter<PedidoState> emit) async {
    late Either<NetworkException, String> result;
    for (final producto in event.products) {
      Map<String, dynamic> data = {
        'id_pedido': event.idPedido,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio
      };

      result = await pedidoUsecase.addDetallePedido(data);
    }
    result.fold(
      (failure) {
        emit(PedidoError(message: failure.message));
        return;
      },
      (success) => emit(PedidoDetalleLoaded(message: success)),
    );
  }

  void _clearPedidoState(Emitter<PedidoState> emit) {
    UtilsVenta.listProductsOrder.clear();
    emit(PedidoInitial());
  }
}
