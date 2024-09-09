import 'package:appexpflutter_update/features/inventarios/domain/entities/medidas_entity_inv.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/cubits/medias/medidas_cubit.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/mixin.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/inventario/inventario_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/lista_productos_bodega.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class InventarioBodega extends StatefulWidget {
  const InventarioBodega({super.key});

  @override
  State<InventarioBodega> createState() => _InventarioBodegaState();
}

class _InventarioBodegaState extends State<InventarioBodega>
    with VerificarCampos {
  bool isMultiSelectMode = false;
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.71, // Altura inicial del modal
      minChildSize: 0.2, // Altura mínima del modal
      maxChildSize: 0.95, // Altura máxima del modal
      builder: (BuildContext context, ScrollController scrollController) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top:
                      20.0), // Ajusta el padding superior para dar espacio a la barra
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'INVENTARIO EN BODEGAS',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colores.secondaryColor,
                              shadows: [
                                const BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(2.0, 5.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMultiSelectMode)
                          BlocBuilder<InventarioBloc, InventarioState>(
                            builder: (context, state) {
                              if (state is InventarioProductosLoaded) {
                                return IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    context.read<ProductosBloc>().add(
                                        AddSelectedProductsToScannedEvent(
                                            state.selectedProducts));

                                    _showModal(
                                      context: context,
                                      icon: const Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.circleCheck,
                                          color: Colors.green,
                                          size: 40,
                                        ),
                                      ),
                                      title: 'Agregado',
                                      menssage:
                                          'Se agrego los productos a la lista',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                    context
                                        .read<InventarioBloc>()
                                        .add(ClearInventarioProductoEvent());
                                    setState(() {
                                      isMultiSelectMode = false;
                                    });
                                  },
                                );
                              }
                              return Container();
                            },
                          ),
                        const SizedBox(height: 10),
                        ReactiveForm(
                          formGroup: form,
                          child: Column(
                            children: [
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
                                  final uniqueMedidas =
                                      medidas.toSet().toList();

                                  // Asegurar de que el valor seleccionado esté en la lista
                                  if (selectedMedida != null &&
                                      !uniqueMedidas.any((medida) =>
                                          medida.medida == selectedMedida)) {
                                    selectedMedida = null;
                                  }

                                  return Container(
                                    width: size.width * 0.9,
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 45),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedMedida,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Seleccione una medida",
                                        labelStyle: const TextStyle(
                                            fontSize: 15, color: Colors.black),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey[400]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey[400]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                        ),
                                      ),
                                      items: uniqueMedidas.map((medida) {
                                        return DropdownMenuItem<String>(
                                          value: medida.medida,
                                          child: Text(
                                            medida.medida,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedMedida = newValue;
                                          // Buscar la medida seleccionada y actualizar los campos
                                          final selected = medidas.firstWhere(
                                              (medida) =>
                                                  medida.medida == newValue);
                                          form.control('mlargo1').value =
                                              '${selected.largo - selected.cm}';
                                          form.control('mlargo2').value =
                                              '${selected.largo + selected.cm}';
                                          form.control('mancho1').value =
                                              '${selected.ancho - selected.cm}';
                                          form.control('mancho2').value =
                                              '${selected.ancho + selected.cm}';
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
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colores.secondaryColor),
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
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: CustomReactiveTextField(
                                                formControlName: 'mlargo2',
                                                hint: 'Largo',
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
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
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: CustomReactiveTextField(
                                                formControlName: 'mancho2',
                                                hint: 'Ancho',
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 80.0),
                                child: ElevatedButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colores.secondaryColor,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
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
                                            color: Colores
                                                .scaffoldBackgroundColor),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    descripcio =
                                        form.control('descripcio').value ?? '';
                                    diseno = form.control('diseno').value ?? '';
                                    mlargo1 = double.tryParse(
                                            form.control('mlargo1').value ??
                                                '0.0') ??
                                        0.0;
                                    mlargo2 = double.tryParse(
                                            form.control('mlargo2').value ??
                                                '0.0') ??
                                        0.0;
                                    mancho1 = double.tryParse(
                                            form.control('mancho1').value ??
                                                '0.0') ??
                                        0.0;
                                    mancho2 = double.tryParse(
                                            form.control('mancho2').value ??
                                                '0.0') ??
                                        0.0;
                                    Map<String, dynamic> data = {};
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
                                    } else if ((mancho1 > 0.0 &&
                                            mancho2 > 0.0) &&
                                        (mlargo1 == 0.0 && mlargo2 == 0.0)) {
                                      data = {
                                        'descripcio': descripcio,
                                        'diseno': diseno,
                                        'mancho1': mancho1,
                                        'mancho2': mancho2,
                                        // 'mancho1': mancho1 - 0.01,
                                        // 'mancho2': mancho2 + 0.01,
                                      };
                                    } else if ((mlargo1 > 0.0 &&
                                            mlargo2 > 0.0) &&
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
                                    context.read<InventarioBloc>().add(
                                        GetInventarioProductEvent(data: data));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        BlocBuilder<InventarioBloc, InventarioState>(
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
                              final selectedProducts = state.selectedProducts;

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: productos.length,
                                itemBuilder: (context, index) {
                                  final producto = productos[index];
                                  final isSelected =
                                      selectedProducts.contains(producto);
                                  final existencia = productos[index].bodega1 +
                                      productos[index].bodega2 +
                                      productos[index].bodega3 +
                                      productos[index].bodega4;
                                  return GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          isMultiSelectMode = true;
                                        });
                                        context
                                            .read<InventarioBloc>()
                                            .add(StartMultiSelectEvent());
                                      },
                                      onTap: () {
                                        if (isMultiSelectMode) {
                                          context.read<InventarioBloc>().add(
                                              ToggleProductSelectionEvent(
                                                  producto));
                                        } else {
                                          context.read<ProductosBloc>().add(
                                              AddProductToScannedEvent(
                                                  producto));

                                          _showModal(
                                            context: context,
                                            icon: const Center(
                                              child: FaIcon(
                                                FontAwesomeIcons.circleCheck,
                                                color: Colors.green,
                                                size: 40,
                                              ),
                                            ),
                                            title: 'Agregado',
                                            menssage:
                                                'Se agrego a la lista el producto con la clave: ${producto.producto1}',
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          );
                                          context.read<InventarioBloc>().add(
                                              ClearInventarioProductoEvent());
                                        }
                                      },
                                      child: ListaProductosBodegaCard(
                                        producto: producto,
                                        isSelected: isSelected,
                                        existencia: existencia.toInt(),
                                        isMultiSelectMode: isMultiSelectMode,
                                      ));
                                },
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
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colores.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showModal(
      {required BuildContext context,
      required String title,
      required String menssage,
      required VoidCallback onPressed,
      final Widget? icon}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: icon,
          title: Text(title),
          content: Text(
            menssage,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colores.secondaryColor,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colores.scaffoldBackgroundColor),
                ),
                onPressed: () {
                  // opcion 1
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
