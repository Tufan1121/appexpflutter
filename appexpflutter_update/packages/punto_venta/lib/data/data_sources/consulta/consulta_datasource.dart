import 'package:punto_venta/data/models/tickets_model.dart';

abstract interface class ConsultaDatasource {
  Future<List<TicketsModel>> getSalesTickets(
      String fechaInicio, String fechaFin);
}
