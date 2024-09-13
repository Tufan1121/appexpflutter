import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventarios/domain/entities/medidas_entity_inv.dart';
import 'package:inventarios/domain/usecases/inventario_expo_usecase.dart';

part 'medidas_state.dart';

class MedidasCubit extends Cubit<MedidasState> {
  final InventarioExpoUsecase inventarioExpoDataSource;
  MedidasCubit({required this.inventarioExpoDataSource})
      : super(MedidasInitial());

  Future<void> getMedidas() async {
    // emit(MedidasLoading());
    final result = await inventarioExpoDataSource.getMedidas();
    result.fold(
      (failure) => emit(MedidasError(message: failure.message)),
      (medidas) {
        emit(MedidasLoaded(medidas: medidas));
      },
    );
  }
}
