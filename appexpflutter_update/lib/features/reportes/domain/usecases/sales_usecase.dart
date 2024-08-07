import 'package:api_client/exceptions/network_exception.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_pedidos_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/entities/sales_tickets_entity.dart';
import 'package:appexpflutter_update/features/reportes/domain/repositories/sales_repository.dart';
import 'package:fpdart/fpdart.dart';

class  SalesUsecase {
  final SalesRepository salesRepository;
  SalesUsecase({required this.salesRepository});

  Future<Either<NetworkException, List<SalesPedidosEntity>>> getSalesPedidos() async {
    return await salesRepository.getSalesPedidos();
  }

  Future<Either<NetworkException, List<SalesTicketsEntity>>> getSalesTickets() async {
    return await salesRepository.getSalesTickets();
  }
}
