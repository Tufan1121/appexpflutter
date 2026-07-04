import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/precios/domain/usecases/producto_usecase.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/inventarios/domain/usecases/inventario_expo_usecase.dart';

part 'precios_event.dart';
part 'precios_state.dart';

class PreciosBloc extends Bloc<PreciosEvent, PreciosState> {
  final ProductoUsecase productoUsecase;
  final InventarioExpoUsecase inventarioExpoUsecase;
  PreciosBloc(
      {required this.productoUsecase, required this.inventarioExpoUsecase})
      : super(PreciosInitial()) {
    on<GetQRProductEvent>(_getQRPreciosEvent);
    on<GetProductEvent>(
      _getPreciosEvent,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<GetRelativedProductsEvent>(_getRelativedProductsEvent);
    on<SelectRelatedProductEvent>(_selectRelatedProductEvent);
    on<ClearPreciosStateEvent>((event, emit) => _clearPreciosState(emit));
  }

  Future<void> _getQRPreciosEvent(
      GetQRProductEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    ProductoEntity? producto;
    result.fold((failure) => emit(PreciosError(message: failure.message)),
        (p) => producto = p);
    if (producto == null) return;
    await _cargarFicha(producto!, emit);
  }

  Future<void> _getPreciosEvent(
      GetProductEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getProductInfo(event.clave);
    ProductoEntity? producto;
    result.fold((failure) => emit(PreciosError(message: failure.message)),
        (p) => producto = p);
    if (producto == null) return;
    await _cargarFicha(producto!, emit);
  }

  /// Tras resolver la clave, busca todas las medidas del mismo diseño en la
  /// búsqueda global (gspock) para mostrar la misma ficha agrupada que en
  /// inventarios. Si no hay resultados (p. ej. sin existencia) o falla la
  /// búsqueda, cae a la tarjeta simple de siempre (PreciosLoaded).
  Future<void> _cargarFicha(
      ProductoEntity producto, Emitter<PreciosState> emit) async {
    final descripcio = producto.descripcio.trim();
    final diseno = producto.diseno.trim();
    if (descripcio.isEmpty && diseno.isEmpty) {
      emit(PreciosLoaded(producto: producto));
      return;
    }
    final result = await inventarioExpoUsecase.getProductoGlobal({
      'descripcio': descripcio,
      'diseno': diseno,
    });
    result.fold(
      (_) => emit(PreciosLoaded(producto: producto)),
      (productos) {
        // El backend busca con LIKE: filtrar al diseño exacto del escaneado.
        final delDiseno = productos
            .where((p) =>
                p.descripcio.trim().toUpperCase() ==
                    descripcio.toUpperCase() &&
                p.diseno.trim().toUpperCase() == diseno.toUpperCase())
            .toList();
        if (delDiseno.isEmpty) {
          emit(PreciosLoaded(producto: producto));
        } else {
          emit(PreciosFichaLoaded(producto: producto, productos: delDiseno));
        }
      },
    );
  }

  Future<void> _getRelativedProductsEvent(
      GetRelativedProductsEvent event, Emitter<PreciosState> emit) async {
    emit(PreciosLoading());

    final result = await productoUsecase.getRelativedProducts(
      event.producto.descripcio,
      event.producto.diseno,
      event.producto.producto,
    );

    result.fold(
        (failure) => emit(PreciosError(message: failure.message)),
        (data) => emit(
            PreciosRelativosLoaded(producto: event.producto, productos: data)));
  }

  Future<void> _selectRelatedProductEvent(
      SelectRelatedProductEvent event, Emitter<PreciosState> emit) async {
    // Verifica si el estado actual es PreciosLoaded
    if (state is PreciosRelativosLoaded) {
      // Extrae el estado actual como PreciosLoaded
      final currentState = state as PreciosRelativosLoaded;

      // Emite un nuevo estado PreciosLoaded con el producto seleccionado actualizado
      emit(PreciosRelativosLoaded(
          producto: event.selectedProduct, productos: currentState.productos));
    }
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

void _clearPreciosState(Emitter<PreciosState> emit) {
    emit(PreciosInitial());
  }
}
