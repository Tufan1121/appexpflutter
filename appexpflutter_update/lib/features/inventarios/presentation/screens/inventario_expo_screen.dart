import 'package:appexpflutter_update/config/router/routes.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_expo/inventario_expo_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/mixin.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/lista_productos_expo.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class InventarioExpoScreen extends StatefulWidget {
  const InventarioExpoScreen({super.key});

  @override
  State<InventarioExpoScreen> createState() => _InventarioExpoScreenState();
}

class _InventarioExpoScreenState extends State<InventarioExpoScreen>
    with VerificarCampos {
  final form = FormGroup({
    'descripcio': FormControl<String>(),
    'diseno': FormControl<String>(),
    'mlargo1': FormControl<String>(),
    'mlargo2': FormControl<String>(),
    'mancho1': FormControl<String>(),
    'mancho2': FormControl<String>(),
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<InventarioExpoBloc>().add(ClearInventarioProductoEvent());
      },
      child: LayoutScreens(
        onPressed: () {
          context
              .read<InventarioExpoBloc>()
              .add(ClearInventarioProductoEvent());
          Navigator.pop(context);
        },
        titleScreen: 'INVENTARIO EXPO',
        child: Column(
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ReactiveForm(
                formGroup: form,
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          'Rango de medidas',
                          style: TextStyle(fontSize: 15, color: Colors.white),
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
                            textStyle: Theme.of(context).textTheme.labelLarge,
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
                          FocusScope.of(context).unfocus();
                          final String descripcio =
                              form.control('descripcio').value ?? '';
                          final String diseno =
                              form.control('diseno').value ?? '';
                          final double mlargo1 = double.tryParse(
                                  form.control('mlargo1').value ?? '0.0') ??
                              0.0;
                          final double mlargo2 = double.tryParse(
                                  form.control('mlargo2').value ?? '0.0') ??
                              0.0;
                          final double mancho1 = double.tryParse(
                                  form.control('mancho1').value ?? '0.0') ??
                              0.0;
                          final double mancho2 = double.tryParse(
                                  form.control('mancho2').value ?? '0.0') ??
                              0.0;
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
                              // 'mlargo1': mlargo1 - 0.01,
                              // 'mlargo2': mlargo2 + 0.01,
                            };
                          } else if ((mancho1 > 0.0 && mancho2 > 0.0) &&
                              (mlargo1 == 0.0 && mlargo2 == 0.0)) {
                            data = {
                              'descripcio': descripcio,
                              'diseno': diseno,
                              'mancho1': mancho1,
                              'mancho2': mancho2,
                              // 'mancho1': mancho1 - 0.01,
                              // 'mancho2': mancho2 + 0.01,
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

                              // 'descripcio': descripcio,
                              // 'diseno': diseno,
                              // 'mlargo1': mlargo1 - 0.01,
                              // 'mlargo2': mlargo2 + 0.01,
                              // 'mancho1': mancho1 - 0.01,
                              // 'mancho2': mancho2 + 0.01,
                            };
                          } else {
                            data = {
                              'descripcio': descripcio,
                              'diseno': diseno,
                            };
                          }
                          context
                              .read<InventarioExpoBloc>()
                              .add(GetInventarioProductEvent(data: data));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            BlocBuilder<InventarioExpoBloc, InventarioExpoState>(
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
                    height: size.height * 0.58,
                    child: ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];

                        List<String> imagePaths = [
                          productos[index].pathima1,
                          productos[index].pathima2,
                          productos[index].pathima3,
                          productos[index].pathima4,
                          productos[index].pathima5,
                          productos[index].pathima6,
                        ].where((path) => path.isNotEmpty).toList();

                        return ListaProductosExpo(
                          producto: producto,
                          onTap: () => PhotoGalleryRoute2(
                            $extra: productos[index],
                            imageUrls: imagePaths,
                            initialIndex: 0,
                          ).push(context),
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
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }
}
