
import 'package:sesion_ventas/domain/entities/pedido_entity.dart';

class PedidoModel extends PedidoEntity{
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
      
  PedidoEntity toEntity() => PedidoEntity(
        idPedido: idPedido,
        pedidos: pedidos,
        idExpo: idExpo,
      );
}
