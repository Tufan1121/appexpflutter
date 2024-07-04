import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/pedido_usecase.dart';

part 'sesion_pedido_event.dart';
part 'sesion_pedido_state.dart';

class SesionPedidoBloc extends Bloc<SesionPedidoEvent, SesionPedidoState> {
  final PedidoUsecase pedidoUsecase;
  SesionPedidoBloc({required this.pedidoUsecase}) : super(PedidoInitial()) {
    on<PedidoAddEvent>(_pedidoAddEvent);
    on<PedidoAddDetalleEvent>(_pedidoAddDetalleEvent);
    on<PedidoAddIdPedidoEvent>(_pedidoAddIdPedidoEvent);
    on<ClearPedidoStateEvent>((event, emit) => _clearPedidoState(emit));
  }

  Future<void> _pedidoAddEvent(
      PedidoAddEvent event, Emitter<SesionPedidoState> emit) async {
    emit(PedidoLoading());
    final result = await pedidoUsecase.addSesionPedido(event.data);

    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (pedido) {
//         print('''
//             Pedido: ${pedido.idPedido}
//             Pedidos: ${pedido.pedidos}
//             expo: ${pedido.idExpo}
//             anticipo: ${event.data['anticipo']}
//             total: ${event.data['total_pagar']}
// ''');
        add(PedidoAddDetalleEvent(pedido: pedido, products: event.products));
        // emit(PedidoLoaded(pedido: pedido));
      },
    );
  }

  Future<void> _pedidoAddDetalleEvent(
      PedidoAddDetalleEvent event, Emitter<SesionPedidoState> emit) async {
    List<Map<String, dynamic>> detallesData = event.products.map((producto) {
      return {
        'id_sesion': event.pedido.idPedido,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
      };
    }).toList();


    final result = await pedidoUsecase.addSesionDetallePedido(detallesData);
    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (success) {
        // add(PedidoAddIdPedidoEvent(pedido: event.pedido));
        emit(PedidoDetalleLoaded(pedido: event.pedido, message: success));
      },
    );
  }

  Future<void> _pedidoAddIdPedidoEvent(
      PedidoAddIdPedidoEvent event, Emitter<SesionPedidoState> emit) async {
    final result = await pedidoUsecase.addIdPedido(event.pedido.idPedido);
    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (success) {
        emit(PedidoDetalleLoaded(pedido: event.pedido, message: success));
      },
    );
  }

  void _clearPedidoState(Emitter<SesionPedidoState> emit) {
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    emit(PedidoInitial());
  }
}
