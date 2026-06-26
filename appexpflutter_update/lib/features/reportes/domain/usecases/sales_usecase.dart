import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_vendedor_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/meta_expo_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/repositories/sales_repository.dart';
import 'package:fpdart/fpdart.dart';

class  SalesUsecase {
  final SalesRepository salesRepository;
  SalesUsecase({required this.salesRepository});

  Future<Either<NetworkException, List<SalesPedidosEntity>>> getSalesPedidos({String? fechaini, String? fechafin}) async {
    return await salesRepository.getSalesPedidos(fechaini: fechaini, fechafin: fechafin);
  }

  Future<Either<NetworkException, List<SalesTicketsEntity>>> getSalesTickets({String? fechaini, String? fechafin}) async {
    return await salesRepository.getSalesTickets(fechaini: fechaini, fechafin: fechafin);
  }

  Future<Either<NetworkException, List<SalesVendedorEntity>>> getSalesByVendedor({String? fechaini, String? fechafin}) async {
    return await salesRepository.getSalesByVendedor(fechaini: fechaini, fechafin: fechafin);
  }

  Future<Either<NetworkException, MetaExpoEntity>> getMetaExpo() async {
    return await salesRepository.getMetaExpo();
  }
}
