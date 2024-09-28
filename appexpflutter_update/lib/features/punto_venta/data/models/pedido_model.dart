import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/pedido_entity.dart';

class PedidoModel extends PedidoEntity
    with EntityConvertible<PedidoModel, PedidoEntity> {
  const PedidoModel({
    required super.idPedido,
    required super.pedidos,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) => PedidoModel(
        idPedido: json["id_pedido"],
        pedidos: json["pedidos"],
      );

  Map<String, dynamic> toJson() => {
        "id_pedido": idPedido,
        "pedidos": pedidos,
      };

  @override
  PedidoEntity toEntity() => PedidoEntity(
        idPedido: idPedido,
        pedidos: pedidos,
      );
}
