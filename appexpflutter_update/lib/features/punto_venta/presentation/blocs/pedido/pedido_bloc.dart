import 'package:appexpflutter_update/features/punto_venta/domain/entities/pedido_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/pedido_usecase.dart';

part 'pedido_event.dart';
part 'pedido_state.dart';

class PedidoVentaBloc extends Bloc<PedidoEvent, PedidoState> {
  final PedidoVentaUsecase pedidoUsecase;
  PedidoVentaBloc({required this.pedidoUsecase}) : super(PedidoInitial()) {
    on<PedidoAddEvent>(_pedidoAddEvent);
    on<PedidoAddDetalleEvent>(_pedidoAddDetalleEvent);
    // on<PedidoAddIdPedidoEvent>(_pedidoAddIdPedidoEvent);
    on<ClearPedidoStateEvent>((event, emit) => _clearPedidoState(emit));
  }

  Future<void> _pedidoAddEvent(
      PedidoAddEvent event, Emitter<PedidoState> emit) async {
    emit(PedidoLoading());
    final result = await pedidoUsecase.addPedido(event.data);

    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (pedido) {
        add(PedidoAddDetalleEvent(pedido: pedido, products: event.products));
      },
    );
  }

  Future<void> _pedidoAddDetalleEvent(
      PedidoAddDetalleEvent event, Emitter<PedidoState> emit) async {
    List<Map<String, dynamic>> detallesData = event.products.map((producto) {
      return {
        'id_pedido': event.pedido.idPedido,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
        'cerrado': 1,
      };
    }).toList();

    final result = await pedidoUsecase.addDetallePedido(detallesData);
    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (success) {
        add(PedidoAddIdPedidoEvent(pedido: event.pedido));
      },
    );
  }

  // Future<void> _pedidoAddIdPedidoEvent(
  //     PedidoAddIdPedidoEvent event, Emitter<PedidoState> emit) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final result = await pedidoUsecase.addIdPedido(event.pedido.idPedido);
  //   result.fold(
  //     (failure) => emit(PedidoError(message: failure.message)),
  //     (success) {
  //       emit(PedidoDetalleLoaded(
  //           username: prefs.getString('username') ?? '',
  //           pedido: event.pedido,
  //           message: success));
  //     },
  //   );
  // }

  void _clearPedidoState(Emitter<PedidoState> emit) {
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    emit(PedidoInitial());
  }
}
