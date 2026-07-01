import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/upper_case_text_formatter.dart';
import 'package:appexpflutter_update/features/inventarios/domain/entities/medidas_entity_inv.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/busqueda_global/busqueda_global_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/cubits/medias/medidas_cubit.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/mixin.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/busqueda_layout.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/producto_card_data.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/productos_result_grid.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/screens/widgets/quiso_decir.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:appexpflutter_update/features/shared/widgets/custom_text_form_field.dart';
import 'package:appexpflutter_update/features/shared/widgets/geometrical_background.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/scanner_page_producto.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class BusquedaGlobalScreen extends StatefulWidget {
  const BusquedaGlobalScreen({super.key});

  @override
  State<BusquedaGlobalScreen> createState() => _BusquedaGlobalScreenState();
}

class _BusquedaGlobalScreenState extends State<BusquedaGlobalScreen>
    with VerificarCampos {
  final form = FormGroup({
    'clave': FormControl<String>(),
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
  final ValueNotifier<bool> _filtrosAbiertos = ValueNotifier<bool>(true);
  // Spinner del botón "buscar por clave" mientras se resuelve `/productScan/`.
  final ValueNotifier<bool> _buscandoClave = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<MedidasCubit>().getMedidas();
  }

  @override
  void dispose() {
    _filtrosAbiertos.dispose();
    _buscandoClave.dispose();
    super.dispose();
  }

  void _clearFilters() {
    form.reset();
    setState(() => selectedMedida = null);
    _filtrosAbiertos.value = true;
    context.read<BusquedaGlobalBloc>().add(ClearInventarioProductoEvent());
    FocusScope.of(context).unfocus();
  }

  void _runSearch() {
    FocusScope.of(context).unfocus();
    descripcio = form.control('descripcio').value ?? '';
    diseno = form.control('diseno').value ?? '';
    mlargo1 = double.tryParse(form.control('mlargo1').value ?? '0.0') ?? 0.0;
    mlargo2 = double.tryParse(form.control('mlargo2').value ?? '0.0') ?? 0.0;
    mancho1 = double.tryParse(form.control('mancho1').value ?? '0.0') ?? 0.0;
    mancho2 = double.tryParse(form.control('mancho2').value ?? '0.0') ?? 0.0;
    if (!isNotEmptyOrWhitespace(descripcio) &&
        !isNotEmptyOrWhitespace(diseno) &&
        mlargo1 == 0.0 &&
        mlargo2 == 0.0 &&
        mancho1 == 0.0 &&
        mancho2 == 0.0) {
      form.markAllAsTouched();
      return;
    }
    Map<String, dynamic> data;
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
        (mancho1 > 0.0 && mancho2 > 0.0)) {
      data = {
        'descripcio': descripcio,
        'diseno': diseno,
        'mlargo1': mlargo1,
        'mlargo2': mlargo2,
        'mancho1': mancho1,
        'mancho2': mancho2,
      };
    } else {
      data = {'descripcio': descripcio, 'diseno': diseno};
    }
    _filtrosAbiertos.value = false;
    context
        .read<BusquedaGlobalBloc>()
        .add(GetInventarioProductEvent(data: data));
  }

  /// Abre la cámara (scanner) y, al detectar un código, lo coloca en el
  /// campo de clave y dispara la búsqueda por clave. Reutiliza el
  /// `ScannerProductoPage` que ya usan ventas/precios.
  Future<void> _escanearClave() async {
    // `onDetect` se dispara en cada frame que detecta el código. Sin este
    // guard, el segundo disparo haría un `pop` de más y cerraría la pantalla.
    bool procesado = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => ScannerProductoPage(
        onDetect: (barcode) {
          if (procesado || barcode.barcodes.isEmpty) return;
          final code = (barcode.barcodes.first.rawValue ?? '').trim();
          if (code.isEmpty) return;
          procesado = true;
          Navigator.of(dialogContext).pop();
          form.control('clave').value = code.toUpperCase();
          _buscarPorClave();
        },
      ),
    );
  }

  /// Resuelve la clave escaneada/tecleada contra `/productScan/`, autollena
  /// los filtros (calidad, color/diseño, largo y ancho) con los datos del
  /// producto y dispara la búsqueda global. Inspirado en `buscarPorClave()`
  /// de la búsqueda global web (`F:\python\galeria\busquedaglobal.html`).
  Future<void> _buscarPorClave() async {
    final clave = (form.control('clave').value as String? ?? '').trim();
    if (clave.isEmpty) return;
    FocusScope.of(context).unfocus();
    _buscandoClave.value = true;

    final usecase = context.read<BusquedaGlobalBloc>().productoUsecase;
    final result = await usecase.getProductoScan(clave);
    if (!mounted) return;
    _buscandoClave.value = false;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(failure.message),
          ));
      },
      (producto) {
        // Autollenar los filtros con los datos del producto encontrado.
        form.control('descripcio').value = producto.descripcio.trim();
        form.control('diseno').value = producto.diseno.trim();
        if (producto.largo > 0) {
          final v = producto.largo.toStringAsFixed(2);
          form.control('mlargo1').value = v;
          form.control('mlargo2').value = v;
        }
        if (producto.ancho > 0) {
          final v = producto.ancho.toStringAsFixed(2);
          form.control('mancho1').value = v;
          form.control('mancho2').value = v;
        }
        // La clave ya cumplió su función: limpiarla, resetear la medida
        // (ahora el rango viene del producto) y lanzar la búsqueda.
        form.control('clave').value = '';
        setState(() => selectedMedida = null);
        _runSearch();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<BusquedaGlobalBloc>().add(ClearInventarioProductoEvent());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: CustomAppBar(
            onPressed: () {
              context
                  .read<BusquedaGlobalBloc>()
                  .add(ClearInventarioProductoEvent());
              Navigator.pop(context);
            },
            title: 'BUSQUEDA GLOBAL',
          ),
        ),
        body: GeometricalBackground(
          child: Column(
              children: [
                const SizedBox(height: 5),
                Expanded(
                  child: BusquedaLayout(
                    abiertoNotifier: _filtrosAbiertos,
                    form: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ReactiveForm(
                    formGroup: form,
                    child: Column(
                      children: [
                        const SizedBox(height: 3),
                        // ── Buscar por clave: resuelve el producto y autollena
                        //    los filtros antes de la búsqueda global. ──
                        CustomReactiveTextField(
                          formControlName: 'clave',
                          hint: 'Buscar por clave',
                          hintStyle: const TextStyle(fontSize: 15),
                          inputFormatters: const [UpperCaseTextFormatter()],
                          onSubmitted: (_) => _buscarPorClave(),
                          prefixIcon: IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colores.secondaryColor,
                            ),
                            tooltip: 'Escanear clave',
                            onPressed: _escanearClave,
                          ),
                          suffixIcon: ValueListenableBuilder<bool>(
                            valueListenable: _buscandoClave,
                            builder: (context, buscando, _) => buscando
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: Colores.secondaryColor,
                                    ),
                                    onPressed: _buscarPorClave,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                    borderSide: const BorderSide(
                                        color: Colores.secondaryColor,
                                        width: 2.0),
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
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
                        Row(
                          children: [
                            // "Limpiar" reubicado aquí (lejos del botón
                            // "Buscar" del fondo) para evitar toques por error.
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.clear_all,
                                  size: 18, color: Colors.white70),
                              label: const Text('Limpiar',
                                  style: TextStyle(color: Colors.white70)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const Spacer(flex: 1),
                            const Text(
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
                                    inputFormatters: [UpperCaseTextFormatter()],
                                  ),
                                  SizedBox(height: 10),
                                  CustomReactiveTextField(
                                    formControlName: 'diseno',
                                    hint: 'Color',
                                    hintStyle: TextStyle(fontSize: 15),
                                    inputFormatters: [UpperCaseTextFormatter()],
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colores.secondaryColor,
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                elevation: 4),
                            onPressed: _runSearch,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                results: BlocBuilder<BusquedaGlobalBloc, BusquedaGlobalState>(
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
                      final productos =
                          ProductoCardData.groupExpo(state.productos);
                      return SizedBox(
                        height: size.height * 0.56,
                        child: ProductosResultGrid(productos: productos),
                      );
                    }
                    if (state is InventarioError) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 80),
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
                            QuisoDecir(
                              descripcio:
                                  form.control('descripcio').value ?? '',
                              onSelected: (sugerencia) {
                                form.control('descripcio').value = sugerencia;
                                context.read<BusquedaGlobalBloc>().add(
                                      GetInventarioProductEvent(data: {
                                        'descripcio': sugerencia,
                                        'diseno':
                                            form.control('diseno').value ?? '',
                                      }),
                                    );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: Container(),
                    );
                  },
                ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
