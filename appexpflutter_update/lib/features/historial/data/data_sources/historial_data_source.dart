import 'package:appexpflutter_update/features/historial/data/models/historial_model.dart';

abstract interface class HistorialDataSource {
  Future<List<HistorialModel>> getHistorial(String parameter, String endpoint);
}
