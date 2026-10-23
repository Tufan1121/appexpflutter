import 'package:appexpflutter_update/features/ventas/domain/entities/cotiza_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/shared/guardado_pendiente.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/pedido_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Avance de la cotización en curso: si falla a medias, el reintento continúa.
  final _guardado = GuardadoPendiente<CotizaEntity>();

  Future<void> _pedidoAddEvent(
      PedidoAddEvent event, Emitter<CotizaPedidoState> emit) async {
    emit(PedidoCotizaLoading());
    _guardado.iniciar(firmaGuardado(event.data, event.products.map(
        (p) => '${p.clave}|${p.cantidad}|${p.precio}|${p.observa}')));
    final previo = _guardado.encabezado;
    if (previo != null) {
      add(_guardado.partidasCompletas
          ? PedidoAddIdPedidoEvent(pedido: previo)
          : PedidoAddDetalleEvent(pedido: previo, products: event.products));
      return;
    }
    final result = await pedidoUsecase.addCotizaPedido(event.data);

    result.fold(
      (failure) => emit(PedidoCotizaError(message: failure.message)),
      (pedido) {
        _guardado.encabezado = pedido;
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
    List<Map<String, dynamic>> detallesData = event.products.map((producto) {
      return {
        'id_cotiza': event.pedido.idCotiza,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
        'observa': producto.observa,
      };
    }).toList();

    // Una partida a la vez para saber cuáles ya quedaron guardadas.
    for (int i = _guardado.partidasGuardadas; i < detallesData.length; i++) {
      final result =
          await pedidoUsecase.addCotizaDetallePedido([detallesData[i]]);
      final error = result.fold((failure) => failure.message, (_) => null);
      if (error != null) {
        emit(PedidoCotizaError(message: error));
        return;
      }
      _guardado.partidasGuardadas = i + 1;
    }
    _guardado.partidasCompletas = true;
    add(PedidoAddIdPedidoEvent(pedido: event.pedido));
  }

  Future<void> _pedidoAddIdPedidoEvent(
      PedidoAddIdPedidoEvent event, Emitter<CotizaPedidoState> emit) async {
        final prefs = await SharedPreferences.getInstance();
    final result = await pedidoUsecase.addIdCotizaPedido(event.pedido.idCotiza);
    result.fold(
      (failure) => emit(PedidoCotizaError(message: failure.message)),
      (success) {
        _guardado.terminar();
        emit(PedidoDetalleCotizaLoaded(username: prefs.getString('username')!, pedido: event.pedido, message: success));
      },
    );
  }

  void _clearPedidoCotizaState(Emitter<CotizaPedidoState> emit) {
    _guardado.terminar();
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    emit(PedidoInitial());
  }
}
