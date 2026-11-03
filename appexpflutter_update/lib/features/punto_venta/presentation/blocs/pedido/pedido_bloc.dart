import 'package:punto_venta/domain/entities/pedido_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:appexpflutter_update/features/shared/guardado_pendiente.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:punto_venta/domain/entities/detalle_pedido_entity.dart';
import 'package:punto_venta/domain/usecases/pedido_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Avance del ticket en curso: si falla a medias, el reintento continúa.
  final _guardado = GuardadoPendiente<PedidoEntity>();

  Future<void> _pedidoAddEvent(
      PedidoAddEvent event, Emitter<PedidoState> emit) async {
    emit(PedidoLoading());
    _guardado.iniciar(firmaGuardado(event.data,
        event.products.map((p) => '${p.clave}|${p.cantidad}|${p.precio}')));
    final previo = _guardado.encabezado;
    if (previo != null) {
      add(PedidoAddDetalleEvent(pedido: previo, products: event.products));
      return;
    }
    final result = await pedidoUsecase.addPedido(event.data);

    result.fold(
      (failure) => emit(PedidoError(message: failure.message)),
      (pedido) {
        _guardado.encabezado = pedido;
        add(PedidoAddDetalleEvent(pedido: pedido, products: event.products));
      },
    );
  }

  Future<void> _pedidoAddDetalleEvent(
      PedidoAddDetalleEvent event, Emitter<PedidoState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> detallesData = [];
    for (int i = 0; i < event.products.length; i++) {
      final producto = event.products[i];
      detallesData.add({
        'id_pedido': event.pedido.idPedido,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
        'observa': producto.observa,
        'cerrado': i == event.products.length - 1 ? 1 : 0,
      });
    }

    // Una partida a la vez para saber cuáles ya quedaron guardadas.
    String mensaje = '';
    for (int i = _guardado.partidasGuardadas; i < detallesData.length; i++) {
      final result = await pedidoUsecase.addDetallePedido([detallesData[i]]);
      final error = result.fold((failure) => failure.message, (ok) {
        mensaje = ok;
        return null;
      });
      if (error != null) {
        emit(PedidoError(message: error));
        return;
      }
      _guardado.partidasGuardadas = i + 1;
    }
    _guardado.terminar();
    emit(PedidoDetalleLoaded(
        username: prefs.getString('username') ?? '',
        pedido: event.pedido,
        message: mensaje));
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
    _guardado.terminar();
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    UtilsVenta.clearShipping();
    UtilsVenta.clearServicios();
    emit(PedidoInitial());
  }
}
