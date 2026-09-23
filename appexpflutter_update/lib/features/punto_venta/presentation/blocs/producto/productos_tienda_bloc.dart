// productos_bloc.dart

import 'package:appexpflutter_update/features/cotizador_envio/data/models/envio_parcial.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/inventario_expo_usecase.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'productos_event.dart';
part 'productos_state.dart';

class ProductosTiendaBloc extends Bloc<ProductosEvent, ProductosState> {
  final InventarioExpoVentaUsecase productoUsecase;
  List<ProductoExpoEntity> scannedProducts = [];

  ProductosTiendaBloc({required this.productoUsecase})
      : super(ProductoInitial()) {
    on<GetQRProductEvent>(_getQRProductEvent);
    on<GetProductEvent>(_getProductEvent
        // transformer: debounce(const Duration(milliseconds: 500)),
        );
    on<AddSelectedProductsToScannedEvent>(_addSelectedProductsToScannedEvent);
    on<RemoveProductEvent>(_removeProductEvent);
    on<ClearProductoStateEvent>((event, emit) => _clearProductsState(emit));

    on<AddProductToScannedEvent>(
      _addProductToScannedEvent,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<UpdateProductEvent>(_updateProductEvent);
  }

  Future<void> _addSelectedProductsToScannedEvent(
      AddSelectedProductsToScannedEvent event,
      Emitter<ProductosState> emit) async {
    scannedProducts.addAll(event.productos);
    // Partidas nuevas con envío ya cotizado: ese envío ya no corresponde.
    if (event.productos.isNotEmpty) {
      UtilsVenta.quitarEnvioPorCambio(
          event.productos.map((p) => p.producto.trim()).join(', '),
          CambioPartida.nueva);
    }
    // if (state is IbodegaProductosLoaded) {
    //   final currentState = state as IbodegaProductosLoaded;
    // }
    emit(ProductosLoaded(productos: List.from(scannedProducts)));
  }

  Future<void> _getQRProductEvent(
      GetQRProductEvent event, Emitter<ProductosState> emit) async {
    emit(ProductoLoading());
    late bool? existencia;

    final result =
        await productoUsecase.getProductoExpo({'producto': event.clave});
    result.fold(
      (failure) {
        if (scannedProducts.any((p) => event.clave == p.producto1.trim())) {
          existencia = false;
          emit(ProductoError(
              productos: scannedProducts,
              message: "No existe o no está disponible",
              existencia: existencia));
          scannedProducts.remove(scannedProducts
              .firstWhere((p) => event.clave == p.producto1.trim()));
          return;
        } else {
          existencia = false;
          emit(ProductoError(
              productos: scannedProducts,
              message: failure.message,
              existencia: existencia));
          return;
        }
      },
      (producto) {
        if (scannedProducts
            .any((p) => p.producto1.trim() == producto.producto1.trim())) {
          existencia = true;
        } else {
          if (!scannedProducts.any((p) => p.producto1 == producto.producto1)) {
            _agregar(producto);
            existencia = true;
          }
        }
        emit(ProductosLoaded(productos: List.from(scannedProducts)));
      },
    );
  }

  /// Agrega una partida nueva. Si ya había envío cotizado, ya no corresponde:
  /// se quita y la lista avisa (UtilsVenta.avisoEnvioQuitado).
  void _agregar(ProductoExpoEntity producto) {
    scannedProducts.add(producto);
    UtilsVenta.quitarEnvioPorCambio(producto.producto, CambioPartida.nueva);
  }

  Future<void> _getProductEvent(
      GetProductEvent event, Emitter<ProductosState> emit) async {
    emit(ProductoLoading());
    late bool? existencia;

    final result =
        await productoUsecase.getProductoExpo({'producto': event.clave});
    result.fold(
      (failure) {
        if (scannedProducts.any((p) => event.clave == p.producto1.trim())) {
          existencia = false;
          emit(ProductoError(
              productos: scannedProducts,
              message: "No existe o no está disponible",
              existencia: existencia));
          scannedProducts.remove(scannedProducts
              .firstWhere((p) => event.clave == p.producto1.trim()));
          return;
        } else {
          existencia = false;
          emit(ProductoError(
              productos: scannedProducts,
              message: failure.message,
              existencia: existencia));
          return;
        }
      },
      (producto) {
        if (scannedProducts
            .any((p) => p.producto1.trim() == producto.producto1.trim())) {
          existencia = true;
        } else {
          if (!scannedProducts.any((p) => p.producto1 == producto.producto1)) {
            _agregar(producto);
            existencia = true;
          }
        }
        emit(ProductosLoaded(
            productos: List.from(scannedProducts), existencia: existencia));
      },
    );
  }

  Future<void> _addProductToScannedEvent(
      AddProductToScannedEvent event, Emitter<ProductosState> emit) async {
    if (!scannedProducts.any((p) => p.producto1 == event.producto.producto1)) {
      _agregar(event.producto);
      emit(ProductosLoaded(productos: List.from(scannedProducts)));
    }
  }

  Future<void> _removeProductEvent(
      RemoveProductEvent event, Emitter<ProductosState> emit) async {
    scannedProducts.remove(event.producto);
    // El envío incluía este tapete: su importe ya no corresponde, así que se
    // quita y se avisa (salvo que el tapete no estuviera cubierto). Va antes
    // de olvidar la partida porque revisa su observación.
    UtilsVenta.quitarEnvioPorCambio(
        event.producto.producto, CambioPartida.eliminada,
        clave: event.producto.producto1);
    UtilsVenta.olvidar(event.producto.producto1);
    if (scannedProducts.isEmpty) {
      // Sin partidas no hay nada que enviar.
      UtilsVenta.clearShipping();
      UtilsVenta.avisoEnvioQuitado = null;
      // Sin productos la lista no se construye, así que el total y el detalle
      // se quedarían con los valores del último producto eliminado.
      UtilsVenta.total = 0;
      UtilsVenta.listProductsOrder.clear();
      UtilsVenta.clearSelecciones();
      emit(ProductoInitial());
    } else {
      emit(ProductosLoaded(productos: List.from(scannedProducts)));
    }
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  void _clearProductsState(Emitter<ProductosState> emit) {
    scannedProducts.clear();
    UtilsVenta.clearSelecciones();
    UtilsVenta.avisoEnvioQuitado = null;
    emit(ProductoInitial());
  }

  /// Maneja el evento de actualización de producto en el Bloc.
  Future<void> _updateProductEvent(
      UpdateProductEvent event, Emitter<ProductosState> emit) async {
    // Mapea la lista de productos escaneados y actualiza el producto que coincide con el producto proporcionado en el evento.
    final updatedProducts = scannedProducts.map((producto) {
      // Si el producto en la lista tiene la misma clave (producto1) que el producto en el evento,
      // reemplázalo con el producto del evento. De lo contrario, deja el producto tal como está.
      return producto.producto1 == event.producto.producto1
          ? event.producto
          : producto;
    }).toList();

    // Actualiza la lista de productos escaneados con la lista de productos actualizada.
    scannedProducts = updatedProducts;

    // Emite un nuevo estado con la lista de productos actualizada.
    emit(ProductosLoaded(productos: List.from(scannedProducts)));
  }
}
