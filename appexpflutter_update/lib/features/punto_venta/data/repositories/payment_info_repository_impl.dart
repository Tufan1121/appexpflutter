import 'package:appexpflutter_update/features/punto_venta/data/data_sources/payment_info/payment_info_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/cuenta_model.dart';
import 'package:appexpflutter_update/features/punto_venta/data/models/terminal_model.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/payment_info_repository.dart';

class PaymentInfoRepositoryImpl implements PaymentInfoRepository {
  final PaymentInfoDataSource dataSource;

  PaymentInfoRepositoryImpl(this.dataSource);

  @override
  Future<List<CuentaModel>> getCuentas() {
    return dataSource.getCuentas();
  }

  @override
  Future<List<TerminalModel>> getTerminales() {
    return dataSource.getTerminales();
  }
}
