import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class SalesRepository {
  Future<Either<NetworkException, List<SalesPedidosEntity>>> getSalesPedidos({String? fechaini, String? fechafin});
  Future<Either<NetworkException, List<SalesTicketsEntity>>> getSalesTickets({String? fechaini, String? fechafin});
  Future<Either<NetworkException, List<SalesVendedorEntity>>> getSalesByVendedor({String? fechaini, String? fechafin});
  Future<Either<NetworkException, MetaExpoEntity>> getMetaExpo();
}