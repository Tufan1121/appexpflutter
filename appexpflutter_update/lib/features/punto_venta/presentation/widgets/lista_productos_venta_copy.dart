import 'package:punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:punto_venta/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class ListaProductosVenta extends HookWidget {
  const ListaProductosVenta({super.key, required this.productos});
  final List<ProductoExpoEntity> productos;

  @override
  Widget build(BuildContext context) {
    final total = useState<double>(0.0);

    // Inicializa las listas con la longitud de productos, llenas de valores predeterminados
    final countList = useState<List<int>>(List.filled(productos.length, 1));
    final customPriceList =
        useState<List<double?>>(List.filled(productos.length, null));
    final selectedPriceList = useState<List<double>>(
        productos.map((e) => e.precio1.toDouble()).toList());
    final dropdownPriceList =
        useState<List<double?>>(List.filled(productos.length, null));

    void updateTotal() {
      double newTotal = 0.0;
      UtilsVenta.listProductsOrder.clear();
      for (var i = 0; i < productos.length; i++) {
        if (i >= countList.value.length ||
            i >= customPriceList.value.length ||
            i >= selectedPriceList.value.length ||
            i >= dropdownPriceList.value.length) {
          continue; // Evita acceder fuera de los límites de las listas
        }

        final count = countList.value[i];
        final customPrice = customPriceList.value[i];
        final selectedPrice = selectedPriceList
            .value[i]; // Siempre tiene el precio seleccionado del checkbox
        final dropdownPrice = dropdownPriceList.value[i];

        // Priorizar el precio del Checkbox (precio1) si está seleccionado
        double precioUnitario = (dropdownPrice == null)
            ? selectedPrice // Aplica el precio del checkbox si no hay dropdown
            : dropdownPrice; // Si hay dropdown, usa el valor seleccionado en él

        // El customPrice solo se aplica si existe y es válido (no afecta el checkbox/dropdown)
        if (customPrice != null) {
          precioUnitario = customPrice;
        }

        final subtotal = precioUnitario * count;
        newTotal += subtotal;

        UtilsVenta.listProductsOrder.add(
          DetallePedidoEntity(
            idPedido: 0,
            clave: productos[i].producto1,
            clave2: productos[i].producto,
            cantidad: count,
            precio: precioUnitario,
          ),
        );
      }
      total.value = newTotal;
      UtilsVenta.total = total.value;
    }

    // Selecciona el precio1 por defecto cuando se inicializa la lista
    useEffect(() {
      // Inicializar con el checkbox seleccionado por defecto (precio1)
      for (var i = 0; i < productos.length; i++) {
        selectedPriceList.value[i] = productos[i].precio1.toDouble();
      }
      updateTotal();
      return null;
    }, [productos.length]);

    return Column(
      children: [
        Text('Total: ${Utils.formatPrice(total.value)}',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colores.secondaryColor,
                shadows: [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2.0, 5.0),
                  )
                ])),
        Scrollbar(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.66,
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                final existencia = productos[index].hm;
                return HookBuilder(
                  builder: (context) {
                    final count = useState(countList.value[index]);
                    final showCustomPrice = useState<bool>(false);
                    final customPrice =
                        useState<double?>(customPriceList.value[index]);
                    final selectedPrice =
                        useState<double>(selectedPriceList.value[index]);
                    final dropdownPrice =
                        useState<double?>(dropdownPriceList.value[index]);
                    final customPriceController = useTextEditingController(
                        text: customPrice.value?.toString() ??
                            producto.precio1.toString());

                    return ClipRect(
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        clipBehavior: Clip.hardEdge,
                        child: Dismissible(
                          direction: DismissDirection.startToEnd,
                          key: Key(producto.producto1),
                          confirmDismiss: (direction) async {
                            return await _dialogEliminar(context, producto);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    FadeInImage(
                                      placeholder: const AssetImage(
                                          'assets/loaders/loading.gif'),
                                      // ignore: unnecessary_null_comparison
                                      image: producto.pathima1 != null &&
                                              producto.pathima1!.isNotEmpty
                                          ? NetworkImage(
                                              'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1 ?? '')}',
                                            )
                                          : const AssetImage(
                                                  'assets/images/no-image.jpg')
                                              as ImageProvider,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/no-image.jpg',
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto.producto,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Clave: ${producto.producto1}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Existencia: ${existencia.toInt()}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            if (count.value <
                                                existencia.toInt()) {
                                              count.value++;
                                              countList.value[index] =
                                                  count.value;
                                              updateTotal();
                                            }
                                          },
                                        ),
                                        Text('${count.value}'),
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            if (count.value > 1) {
                                              count.value--;
                                              countList.value[index] =
                                                  count.value;
                                              updateTotal();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Scrollbar(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildPriceCheckbox(
                                          context: context,
                                          label: 'Precio de Lista',
                                          price: producto.precio1.toDouble(),
                                          value: selectedPrice.value ==
                                              producto.precio1.toDouble(),
                                          onChanged: (bool? value) {
                                            if (value == true) {
                                              // Volver al precio de lista (precio1) cuando el checkbox esté seleccionado
                                              selectedPrice.value =
                                                  producto.precio1.toDouble();
                                              dropdownPrice.value =
                                                  null; // Limpiar el dropdown
                                              dropdownPriceList.value[index] =
                                                  null; // Asegurarnos que el valor del dropdown sea null
                                            } else {
                                              // Si desmarcan el checkbox, vuelve al valor del dropdown o al precio1
                                              selectedPrice.value =
                                                  dropdownPrice.value ??
                                                      producto.precio1
                                                          .toDouble();
                                            }

                                            selectedPriceList.value[index] =
                                                selectedPrice.value;
                                            updateTotal(); // Recalcular el total al cambiar el checkbox
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colores.secondaryColor,
                                          ),
                                          onPressed: () {
                                            showCustomPrice.value =
                                                !showCustomPrice.value;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (showCustomPrice.value)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 32,
                                        child: TextField(
                                          controller: customPriceController,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            customPrice.value =
                                                double.tryParse(value);
                                          },
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height: 33,
                                        width: 110,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colores.secondaryColor,
                                          ),
                                          onPressed: customPrice.value != null
                                              ? () {
                                                  FocusScope.of(context)
                                                      .unfocus();

                                                  // Parsear el valor del customPriceController
                                                  final price = double.tryParse(
                                                      customPriceController
                                                          .text);

                                                  if (price != null) {
                                                    // Actualiza el precio personalizado (customPrice)
                                                    customPriceList
                                                        .value[index] = price;

                                                    // Actualiza el producto con el nuevo precio
                                                    final updatedProduct =
                                                        producto.copyWith(
                                                            precio1:
                                                                price.toInt());

                                                    context
                                                        .read<
                                                            ProductosTiendaBloc>()
                                                        .add(UpdateProductEvent(
                                                            updatedProduct));

                                                    // Actualiza el producto en la lista de productos locales
                                                    productos[index] =
                                                        updatedProduct;

                                                    // Refrescar el total con el nuevo precio
                                                    updateTotal();

                                                    // Mostrar el precio actualizado en la UI (opcional)
                                                    selectedPriceList
                                                        .value[index] = price;
                                                  }
                                                }
                                              : null,
                                          child: const AutoSizeText(
                                            'APLICAR PRECIO',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colores
                                                  .scaffoldBackgroundColor,
                                            ),
                                            minFontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  width: 10,
                                ),
                                _buildPriceDropdown(
                                  context: context,
                                  producto: producto,
                                  dropdownPrice: dropdownPrice,
                                  dropdownPriceList: dropdownPriceList,
                                  index: index,
                                  selectedPrice: selectedPrice,
                                  updateTotal: updateTotal,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCheckbox({
    required BuildContext context,
    required String label,
    required double price,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colores.secondaryColor,
        ),
        Row(
          children: [
            Text(
              '$label : ',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              Utils.formatPrice(price),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDropdown({
    required BuildContext context,
    required ProductoExpoEntity producto,
    required ValueNotifier<double?> dropdownPrice,
    required ValueNotifier<List<double?>> dropdownPriceList,
    required ValueNotifier<double?> selectedPrice,
    required int index,
    required VoidCallback updateTotal,
  }) {
    // Lista de promociones (precios)
    final promociones = [
      if (producto.precio4 != null) producto.precio4?.toDouble(),
      if (producto.precio5 != null) producto.precio5?.toDouble(),
      if (producto.precio6 != null) producto.precio6?.toDouble(),
      if (producto.precio7 != null) producto.precio7?.toDouble(),
      if (producto.precio8 != null) producto.precio8?.toDouble(),
      if (producto.precio9 != null) producto.precio9?.toDouble(),
      if (producto.precio10 != null) producto.precio10?.toDouble(),
    ];

    // Lista de descuentos en porcentaje que corresponde a las promociones
    final descuentos = [
      '-20%',
      '-25%',
      '-30%',
      '-35%',
      '-40%',
      '-50%',
      '-70%',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promoción:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 200,
          height: 40,
          child: DropdownButtonHideUnderline(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8), // Reducir padding
              decoration: BoxDecoration(
                border: Border.all(color: Colores.secondaryColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<double>(
                isExpanded:
                    true, // Permite que el Dropdown ocupe todo el ancho disponible
                value: dropdownPrice.value,
                hint: const Text(
                  'Seleccione una promoción',
                  style: TextStyle(fontSize: 12), // Texto más pequeño
                ),
                onChanged: (double? newValue) {
                  if (newValue != null) {
                    dropdownPrice.value = newValue;
                    dropdownPriceList.value[index] = newValue;

                    // Desmarcar el checkbox cuando se selecciona una promoción
                    selectedPrice.value = newValue;
                  }
                  updateTotal();
                },
                items: List<DropdownMenuItem<double>>.generate(
                  promociones.length,
                  (i) => DropdownMenuItem(
                    value: promociones[i],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          descuentos[i], // Mostrar el porcentaje de descuento
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          Utils.formatPrice(promociones[i] ??
                              0.0), // Mostrar el precio de la promoción
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _dialogEliminar(
      BuildContext context, ProductoExpoEntity producto) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning,
            color: Colors.red,
          ),
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: Colors.red),
          ),
          content:
              Text('¿Está seguro de que desea eliminar ${producto.producto}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancelar la eliminación
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colores.secondaryColor),
              ),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colores.secondaryColor,
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colores.scaffoldBackgroundColor),
              ),
              onPressed: () {
                context
                    .read<ProductosTiendaBloc>()
                    .add(RemoveProductEvent(producto));
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
