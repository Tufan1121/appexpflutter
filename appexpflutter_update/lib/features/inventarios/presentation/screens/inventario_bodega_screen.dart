import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/medidas_entity_inv.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_bodega/inventario_bodega_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/cubits/medias/medidas_cubit.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/mixin.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/lista_productos_ibodega.dart';
import 'package:appexpflutter_update/features/shared/widgets/background_painter.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class InventarioBodegaScreen extends StatefulWidget {
  const InventarioBodegaScreen({super.key});

  @override
  State<InventarioBodegaScreen> createState() => _InventarioBodegaScreenState();
}

class _InventarioBodegaScreenState extends State<InventarioBodegaScreen>
    with VerificarCampos {
  final form = FormGroup({
    'descripcio': FormControl<String>(),
    'diseno': FormControl<String>(),
    'mlargo1': FormControl<String>(),
    'mlargo2': FormControl<String>(),
    'mancho1': FormControl<String>(),
    'mancho2': FormControl<String>(),
  });
  final List<MedidasEntityInv> medidas = [];
  late String descripcio;
  late String diseno;
  late double mlargo1;
  late double mlargo2;
  late double mancho1;
  late double mancho2;
  String? selectedMedida;

  @override
  void initState() {
    super.initState();
    context.read<MedidasCubit>().getMedidas();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context
            .read<InventarioBodegaBloc>()
            .add(ClearInventarioProductoEvent());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: CustomAppBar(
            onPressed: () {
              context
                  .read<InventarioBodegaBloc>()
                  .add(ClearInventarioProductoEvent());
              Navigator.pop(context);
            },
            title: 'INVENTARIO BODEGAS',
          ),
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: BackgroundPainter(),
            ),
            Column(
              children: [
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ReactiveForm(
                    formGroup: form,
                    child: Column(
                      children: [
                        const SizedBox(height: 3),
                        BlocBuilder<MedidasCubit, MedidasState>(
                          builder: (context, state) {
                            if (state is MedidasLoaded) {
                              medidas.clear();
                              medidas.addAll(state.medidas);
                            } else if (state is MedidasError) {
                              medidas.clear();
                              medidas.add(MedidasEntityInv(
                                  medida: 'Error al cargar medidas',
                                  largo: 0,
                                  cm: 0,
                                  ancho: 0));
                            }

                            // Asegurar de que no haya duplicados
                            // Asegurar de que no haya duplicados
                            final uniqueMedidas = medidas.toSet().toList();

                            // Asegurar de que el valor seleccionado esté en la lista
                            if (selectedMedida != null &&
                                !uniqueMedidas.any((medida) =>
                                    medida.medida == selectedMedida)) {
                              selectedMedida = null;
                            }

                            return Container(
                              width: size.width * 0.9,
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 45),
                              child: DropdownButtonFormField<String>(
                                value: selectedMedida,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Seleccione una medida",
                                  labelStyle: const TextStyle(
                                      fontSize: 15, color: Colors.black),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey[400]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey[400]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                items: uniqueMedidas.map((medida) {
                                  return DropdownMenuItem<String>(
                                    value: medida.medida,
                                    child: Text(
                                      medida.medida,
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMedida = newValue;
                                    // Buscar la medida seleccionada y actualizar los campos
                                    final selected = medidas.firstWhere(
                                        (medida) => medida.medida == newValue);
                                    form.control('mlargo1').value =
                                        (selected.largo - selected.cm)
                                            .toStringAsFixed(2);
                                    form.control('mlargo2').value =
                                        (selected.largo + selected.cm)
                                            .toStringAsFixed(2);
                                    form.control('mancho1').value =
                                        (selected.ancho - selected.cm)
                                            .toStringAsFixed(2);
                                    form.control('mancho2').value =
                                        (selected.ancho + selected.cm)
                                            .toStringAsFixed(2);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        const Row(
                          children: [
                            Spacer(
                              flex: 1,
                            ),
                            Text(
                              'Rango de medidas',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  CustomReactiveTextField(
                                    formControlName: 'descripcio',
                                    hint: 'Calidad',
                                    hintStyle: TextStyle(fontSize: 15),
                                    errorStyle: TextStyle(
                                        color: Colores.scaffoldBackgroundColor),
                                  ),
                                  SizedBox(height: 10),
                                  CustomReactiveTextField(
                                    formControlName: 'diseno',
                                    hint: 'Color',
                                    hintStyle: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomReactiveTextField(
                                          formControlName: 'mlargo1',
                                          hint: 'Largo',
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          hintStyle: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: CustomReactiveTextField(
                                          formControlName: 'mlargo2',
                                          hint: 'Largo',
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          hintStyle: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomReactiveTextField(
                                          formControlName: 'mancho1',
                                          hint: 'Ancho',
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          hintStyle: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: CustomReactiveTextField(
                                          formControlName: 'mancho2',
                                          hint: 'Ancho',
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          hintStyle: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80.0),
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colores.secondaryColor,
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                elevation: 4),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colores.scaffoldBackgroundColor,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Buscar',
                                  style: TextStyle(
                                      color: Colores.scaffoldBackgroundColor),
                                ),
                              ],
                            ),
                            onPressed: () {
                              descripcio =
                                  form.control('descripcio').value ?? '';
                              diseno = form.control('diseno').value ?? '';
                              mlargo1 = double.tryParse(
                                      form.control('mlargo1').value ?? '0.0') ??
                                  0.0;
                              mlargo2 = double.tryParse(
                                      form.control('mlargo2').value ?? '0.0') ??
                                  0.0;
                              mancho1 = double.tryParse(
                                      form.control('mancho1').value ?? '0.0') ??
                                  0.0;
                              mancho2 = double.tryParse(
                                      form.control('mancho2').value ?? '0.0') ??
                                  0.0;

                              FocusScope.of(context).unfocus();
                              if (!isNotEmptyOrWhitespace(descripcio) &&
                                  !isNotEmptyOrWhitespace(diseno) &&
                                  mlargo1 == 0.0 &&
                                  mlargo2 == 0.0 &&
                                  mancho1 == 0.0 &&
                                  mancho2 == 0.0) {
                                form.markAllAsTouched();
                                return;
                              }
                              Map<String, dynamic> data = {};
                              if ((mlargo1 > 0.0 && mlargo2 > 0.0) &&
                                  (mancho1 == 0.0 && mancho2 == 0.0)) {
                                data = {
                                  'descripcio': descripcio,
                                  'diseno': diseno,
                                  'mlargo1': mlargo1,
                                  'mlargo2': mlargo2,
                                };
                              } else if ((mancho1 > 0.0 && mancho2 > 0.0) &&
                                  (mlargo1 == 0.0 && mlargo2 == 0.0)) {
                                data = {
                                  'descripcio': descripcio,
                                  'diseno': diseno,
                                  'mancho1': mancho1,
                                  'mancho2': mancho2,
                                };
                              } else if ((mlargo1 > 0.0 && mlargo2 > 0.0) &&
                                  (mlargo1 > 0.0 && mlargo2 > 0.0)) {
                                data = {
                                  'descripcio': descripcio,
                                  'diseno': diseno,
                                  'mlargo1': mlargo1,
                                  'mlargo2': mlargo2,
                                  'mancho1': mancho1,
                                  'mancho2': mancho2,
                                };
                              } else {
                                data = {
                                  'descripcio': descripcio,
                                  'diseno': diseno,
                                };
                              }
                              context
                                  .read<InventarioBodegaBloc>()
                                  .add(GetInventarioProductEvent(data: data));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                BlocBuilder<InventarioBodegaBloc, InventarioBodegaState>(
                  builder: (context, state) {
                    if (state is InventarioLoading) {
                      return const Column(
                        children: [
                          SizedBox(height: 150),
                          CircularProgressIndicator(
                            color: Colores.secondaryColor,
                          ),
                        ],
                      );
                    }
                    if (state is InventarioProductosLoaded) {
                      final productos = state.productos;

                      return SizedBox(
                        height: size.height * 0.56,
                        child: ListView.builder(
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final producto = productos[index];
                            final existencia = productos[index].bodega1 +
                                productos[index].bodega2 +
                                productos[index].bodega3 +
                                productos[index].bodega4;

                            List<String> imagePaths = [
                              productos[index].pathima1,
                              productos[index].pathima2,
                              productos[index].pathima3,
                              productos[index].pathima4,
                              productos[index].pathima5,
                              productos[index].pathima6,
                            ].where((path) => path.isNotEmpty).toList();

                            return ListaProductosIBodegaCard(
                              producto: producto,
                              existencia: existencia.toInt(),
                              onTap: () => PhotoGalleryIBodegasRoute(
                                      $extra: producto,
                                      imageUrls: imagePaths,
                                      initialIndex: 0)
                                  .push(context),
                            );
                          },
                        ),
                      );
                    }
                    if (state is InventarioError) {
                      return Column(
                        children: [
                          const SizedBox(height: 150),
                          Center(
                            child: SizedBox(
                              height: 60,
                              width: 300,
                              child: Card(
                                child: AutoSizeText(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(
                      child: Container(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
