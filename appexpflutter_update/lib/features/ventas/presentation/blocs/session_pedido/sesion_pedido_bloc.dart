import 'package:appexpflutter_update/features/ventas/domain/entities/sesion_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/shared/guardado_pendiente.dart';
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

  // Avance de la sesión en curso: si falla a medias, el reintento continúa.
  final _guardado = GuardadoPendiente<SesionEntity>();

  Future<void> _pedidoAddEvent(
      PedidoAddSesionEvent event, Emitter<SesionPedidoState> emit) async {
    emit(PedidoSesionLoading());
    _guardado.iniciar(firmaGuardado(event.data, event.products.map(
        (p) => '${p.clave}|${p.cantidad}|${p.precio}|${p.observa}')));
    final previo = _guardado.encabezado;
    if (previo != null) {
      add(PedidoAddDetalleEvent(pedido: previo, products: event.products));
      return;
    }
    final result = await pedidoUsecase.addSesionPedido(event.data);

    result.fold(
      (failure) => emit(PedidoSesionError(message: failure.message)),
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
      PedidoAddDetalleEvent event, Emitter<SesionPedidoState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> detallesData = event.products.map((producto) {
      return {
        'id_sesion': event.pedido.idSesion,
        'clave': producto.clave,
        'clave2': producto.clave2,
        'cantidad': producto.cantidad,
        'precio': producto.precio,
        'observa': producto.observa,
      };
    }).toList();

    // Una partida a la vez para saber cuáles ya quedaron guardadas.
    String mensaje = '';
    for (int i = _guardado.partidasGuardadas; i < detallesData.length; i++) {
      final result =
          await pedidoUsecase.addSesionDetallePedido([detallesData[i]]);
      final error = result.fold((failure) => failure.message, (ok) {
        mensaje = ok;
        return null;
      });
      if (error != null) {
        emit(PedidoSesionError(message: error));
        return;
      }
      _guardado.partidasGuardadas = i + 1;
    }
    _guardado.terminar();
    emit(PedidoDetalleSesionLoaded(
        username: prefs.getString('username') ?? '',
        pedido: event.pedido,
        message: mensaje));
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
    _guardado.terminar();
    UtilsVenta.listProductsOrder.clear();
    UtilsVenta.total = 0.0;
    emit(PedidoSesionInitial());
  }
}
