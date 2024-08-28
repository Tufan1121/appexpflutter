import 'package:appexpflutter_update/features/galeria/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/producto_inv_entity.dart';
import 'package:appexpflutter_update/features/galeria/domain/entities/tabla_precio_entity.dart';
import 'package:equatable/equatable.dart';

class ProductoConExistencias extends Equatable {
  final ProductoGalEntity  producto;
  final List<ProductoInvEntity> existencias;
  final List<TablaPreciosEntity> tablaPrecios;

  const ProductoConExistencias({required this.producto, required this.existencias, required this.tablaPrecios});

  @override
  List<Object?> get props => [producto, existencias, tablaPrecios];
}
