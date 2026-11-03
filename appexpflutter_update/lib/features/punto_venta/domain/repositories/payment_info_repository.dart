import 'package:appexpflutter_update/features/punto_venta/data/models/cuenta_model.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/terminal_model.dart';

abstract class PaymentInfoRepository {
  Future<List<CuentaModel>> getCuentas();
  Future<List<TerminalModel>> getTerminales();
}
