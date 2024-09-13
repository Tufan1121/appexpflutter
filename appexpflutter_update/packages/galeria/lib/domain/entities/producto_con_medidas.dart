
import 'package:equatable/equatable.dart';
import 'package:galeria/domain/entities/medidas_entity.dart';
import 'package:galeria/domain/entities/producto_entity.dart';

class ProductoConMedidas extends Equatable {
  final ProductoGalEntity  producto;
  final List<MedidasEntity> medidas;

  const ProductoConMedidas({required this.producto, required this.medidas});

  @override
  List<Object?> get props => [producto, medidas];
}
