import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:sesion_ventas/domain/entities/pedido_entity.dart';
import 'package:sesion_ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:sesion_ventas/domain/entities/cotiza_entity.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesion_ventas/domain/usecases/pedido_usecase.dart';

part 'cotiza_pedido_event.dart';
part 'cotiza_pedido_state.dart';

class CotizaPedidoBloc extends Bloc<CotizaPedidoEvent, CotizaPedidoState> {
  final PedidoUsecase pedidoUsecase;
  CotizaPedidoBloc({required this.pedidoUsecase}) : super(PedidoInitial()) {
    on<PedidoAddEvent>(_pedidoAddEvent);
    on<PedidoAddDetalleEvent>(_pedidoAddDetalleEvent);
    on<PedidoAddIdPedidoEvent>(_pedidoAddIdPedidoEvent);
    on<ClearPedidoCotizaEvent>((event, emit) => _clearPedidoCotizaState(emit));
  }

  Future<void> _pedidoAddEvent(
      PedidoAddEvent event, Emitter<CotizaPedidoState> emit) async {
    emit(PedidoCotizaLoading());
    final result = await pedidoUsecase.addCotizaPedido(event.data);

    result.fold(
      (failure) => emit(PedidoCotizaError(message: failure.message)),
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
      PedidoAddDetalleEvent event, Emitter<CotizaPedidoState> emit) async {
    List<Map<String, dynamic>> detallesData = event.products.map((dynamic producto) {
      return {
        'id_cotiza': event.pedido.idCotiza,
        'clave': producto?.clave,
        'clave2': producto!.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
      };
    }).toList();

    final result = await pedidoUsecase.addCotizaDetallePedido(detallesData);
    result.fold(
      (failure) => emit(PedidoCotizaError(message: failure.message)),
      (success) {
        add(PedidoAddIdPedidoEvent(pedido: event.pedido));
        // emit(PedidoDetalleLoaded(pedido: event.pedido, message: success));
      },
    );
  }

  Future<void> _pedidoAddIdPedidoEvent(
      PedidoAddIdPedidoEvent event, Emitter<CotizaPedidoState> emit) async {
        final prefs = await SharedPreferences.getInstance();
    final result = await pedidoUsecase.addIdCotizaPedido(event.pedido.idCotiza);
    result.fold(
      (failure) => emit(PedidoCotizaError(message: failure.message)),
      (success) {
        emit(PedidoDetalleCotizaLoaded(username: prefs.getString('username')!, pedido: event.pedido, message: success));
      },
    );
  }

  void _clearPedidoCotizaState(Emitter<CotizaPedidoState> emit) {
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    emit(PedidoInitial());
  }
}
