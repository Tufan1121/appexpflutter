import 'package:appexpflutter_update/config/mappers/entity_convertable.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/pedido_entity.dart';

class PedidoModel extends PedidoEntity
    with EntityConvertible<PedidoModel, PedidoEntity> {
  const PedidoModel({
    required super.idPedido,
    required super.pedidos,
    required super.idExpo,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) => PedidoModel(
        idPedido: json["id_pedido"],
        pedidos: json["pedidos"],
        idExpo: json["id_expo"],
      );

  Map<String, dynamic> toJson() => {
        "id_pedido": idPedido,
        "pedidos": pedidos,
        "id_expo": idExpo,
      };

  @override
  PedidoEntity toEntity() => PedidoEntity(
        idPedido: idPedido,
        pedidos: pedidos,
        idExpo: idExpo,
      );
}
