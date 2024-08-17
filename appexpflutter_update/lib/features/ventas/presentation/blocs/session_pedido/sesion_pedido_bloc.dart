import 'package:appexpflutter_update/features/ventas/domain/entities/sesion_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/pedido_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sesion_pedido_event.dart';
part 'sesion_pedido_state.dart';

class SesionPedidoBloc extends Bloc<SesionPedidoEvent, SesionPedidoState> {
  final PedidoUsecase pedidoUsecase;
  SesionPedidoBloc({required this.pedidoUsecase})
      : super(PedidoSesionInitial()) {
    on<PedidoAddSesionEvent>(_pedidoAddEvent);
    on<PedidoAddDetalleEvent>(_pedidoAddDetalleEvent);
    on<PedidoAddIdSesionEvent>(_pedidoFinalSesionEvent);
    on<ClearPedidoSesionEvent>((event, emit) => _clearPedidoSesionState(emit));
  }

  Future<void> _pedidoAddEvent(
      PedidoAddSesionEvent event, Emitter<SesionPedidoState> emit) async {
    emit(PedidoSesionLoading());
    final result = await pedidoUsecase.addSesionPedido(event.data);

    result.fold(
      (failure) => emit(PedidoSesionError(message: failure.message)),
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
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> detallesData = event.products.map((producto) {
      return {
        'id_sesion': event.pedido.idSesion,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
      };
    }).toList();

    final result = await pedidoUsecase.addSesionDetallePedido(detallesData);
    result.fold(
      (failure) => emit(PedidoSesionError(message: failure.message)),
      (success) {
        // add(PedidoAddIdPedidoEvent(pedido: event.pedido));
        emit(PedidoDetalleSesionLoaded(
            username: prefs.getString('username') ?? '',
            pedido: event.pedido,
            message: success));
      },
    );
  }

  Future<void> _pedidoFinalSesionEvent(
      PedidoAddIdSesionEvent event, Emitter<SesionPedidoState> emit) async {
    final result = await pedidoUsecase.finalSesion(event.idSesion);
    result.fold(
      (failure) => emit(PedidoSesionError(message: failure.message)),
      (success) {
        emit(PedidoFinalSesionLoaded(message: success));
      },
    );
  }

  void _clearPedidoSesionState(Emitter<SesionPedidoState> emit) {
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    emit(PedidoSesionInitial());
  }
}
