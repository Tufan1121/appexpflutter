import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
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
      (pedido) {
        print('''
            Pedido: ${pedido.idPedido}
            Pedidos: ${pedido.pedidos}
            expo: ${pedido.idExpo}

            
''');
        add(PedidoAddDetalleEvent(pedido: pedido, products: event.products));
        emit(PedidoLoaded(pedido: pedido));
      },
    );
  }

  Future<void> _pedidoAddDetalleEvent(
      PedidoAddDetalleEvent event, Emitter<PedidoState> emit) async {
    // late Either<NetworkException, String> result;
    bool hasFailure = false;

    for (final producto in event.products) {
      Map<String, dynamic> data = {
        'id_pedido': event.pedido.idPedido,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio
      };

      print(data);

      final result = await pedidoUsecase.addDetallePedido(data);
      result.fold(
        (failure) {
          emit(PedidoError(message: failure.message));
          hasFailure = true;
          return;
        },
        (success) {},
      );

      if (hasFailure) {
        return; // Exit the method if there's a failure
      }
    }

    // Emit the success state once, after all products are added
    if (!hasFailure) {
      emit(PedidoDetalleLoaded(
          pedido: event.pedido,
          message: 'Detalles del pedido agregados con éxito'));
    }
  }

  void _clearPedidoState(Emitter<PedidoState> emit) {
    UtilsVenta.listProductsOrder.clear();
    emit(PedidoInitial());
  }
}
