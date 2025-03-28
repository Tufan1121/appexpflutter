
import 'package:punto_venta/domain/entities/pedido_entity.dart';

class PedidoModel extends PedidoEntity {
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

  PedidoEntity toEntity() => PedidoEntity(
        idPedido: idPedido,
        pedidos: pedidos,
      );
}
