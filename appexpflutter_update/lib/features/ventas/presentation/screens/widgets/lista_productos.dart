import 'package:sesion_ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:precios/domain/entities/producto_entity.dart';

class ListaProductos extends HookWidget {
  const ListaProductos({super.key, required this.productos});
  final List<ProductoEntity> productos;

  @override
  Widget build(BuildContext context) {
    final total = useState<double>(0.0);
    final scrollController = useScrollController();
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
        final selectedPrice = selectedPriceList.value[i];
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

    useEffect(() {
      updateTotal();
      return null;
    }, [
      countList.value,
      customPriceList.value,
      selectedPriceList.value,
      dropdownPriceList.value
    ]);

    // Sincroniza las listas auxiliares con la lista principal de productos
    useEffect(() {
      final newCountList = List<int>.from(countList.value);
      final newCustomPriceList = List<double?>.from(customPriceList.value);
      final newSelectedPriceList = List<double>.from(selectedPriceList.value);
      final newDropdownPriceList = List<double?>.from(dropdownPriceList.value);

      if (newCountList.length < productos.length) {
        newCountList.addAll(
            List<int>.filled(productos.length - newCountList.length, 1));
        newCustomPriceList.addAll(List<double?>.filled(
            productos.length - newCustomPriceList.length, null));
        newSelectedPriceList.addAll(productos
            .sublist(newSelectedPriceList.length)
            .map((e) => e.precio1.toDouble())
            .toList());
        newDropdownPriceList.addAll(List<double?>.filled(
            productos.length - newDropdownPriceList.length, null));
      } else if (newCountList.length > productos.length) {
        newCountList.removeRange(productos.length, newCountList.length);
        newCustomPriceList.removeRange(
            productos.length, newCustomPriceList.length);
        newSelectedPriceList.removeRange(
            productos.length, newSelectedPriceList.length);
        newDropdownPriceList.removeRange(
            productos.length, newDropdownPriceList.length);
      }

      countList.value = newCountList;
      customPriceList.value = newCustomPriceList;
      selectedPriceList.value = newSelectedPriceList;
      dropdownPriceList.value = newDropdownPriceList;

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
          controller: scrollController,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.66,
            child: ListView.builder(
              // Asignamos el mismo controlador al ListView
              scrollDirection: Axis.vertical,
              controller: scrollController,
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                final existencia = productos[index].bodega1 +
                    productos[index].bodega2 +
                    productos[index].bodega3 +
                    productos[index].bodega4;
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
                                      image: producto.pathima1.isNotEmpty
                                          ? NetworkImage(
                                              'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
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
                                SingleChildScrollView(
                                  //scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                null;
                                          } else {
                                            selectedPrice.value =
                                                dropdownPrice.value ??
                                                    producto.precio1.toDouble();
                                          }

                                          selectedPriceList.value[index] =
                                              selectedPrice.value;
                                          updateTotal(); // Recalcular el total al cambiar el checkbox
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          showCustomPrice.value =
                                              !showCustomPrice.value;
                                        },
                                      ),
                                    ],
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

                                                  final price = double.tryParse(
                                                      customPriceController
                                                          .text);

                                                  if (price != null) {
                                                    customPriceList
                                                        .value[index] = price;

                                                    final updatedProduct =
                                                        producto.copyWith(
                                                            precio1:
                                                                price.toInt());

                                                    context
                                                        .read<ProductosBloc>()
                                                        .add(UpdateProductEvent(
                                                            updatedProduct));

                                                    productos[index] =
                                                        updatedProduct;

                                                    updateTotal();
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
                                const SizedBox(width: 10),
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
    required ProductoEntity producto,
    required ValueNotifier<double?> dropdownPrice,
    required ValueNotifier<List<double?>> dropdownPriceList,
    required ValueNotifier<double?> selectedPrice,
    required int index,
    required VoidCallback updateTotal,
  }) {
    // Lista de promociones (precios) - la lista necesita ser mutable si el precio cambia
    final promociones = useState<List<double?>>([
      producto.precio8.toDouble(),
      if (producto.precio9 != null) producto.precio9?.toDouble(),
      producto.precio4.toDouble(),
      if (producto.precio10 != null) producto.precio10?.toDouble(),
      producto.precio5.toDouble(),
      producto.precio6.toDouble(),
      producto.precio7.toDouble(),
    ]);

    // Variable para almacenar el valor editado antes de aplicarlo
    final editPrice = useState<double?>(null);

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

    final showCustomPriceDropdown = useState<bool>(
        false); // Controla la visibilidad del TextField para editar el precio de promoción
    final customPriceController =
        useTextEditingController(); // Controlador para el TextField de edición de precio

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promoción:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            // DropdownButton para seleccionar la promoción
            SizedBox(
              width: 200,
              height: 40,
              child: DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8), // Reducir padding
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

                        // Al seleccionar una promoción, actualiza la variable temporal `editPrice` con el valor actual
                        editPrice.value = newValue;

                        // Desmarcar el checkbox cuando se selecciona una promoción
                        selectedPrice.value = newValue;

                        // Actualiza el total
                        updateTotal();
                      }
                    },
                    items: List<DropdownMenuItem<double>>.generate(
                      promociones.value.length,
                      (i) => DropdownMenuItem(
                        value: promociones.value[i],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              descuentos[
                                  i], // Mostrar el porcentaje de descuento
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              Utils.formatPrice(promociones.value[i] ??
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

            // Botón para editar el precio del Dropdown
            IconButton(
              icon: Icon(
                Icons.edit,
                color: dropdownPrice.value != null
                    ? Colores.secondaryColor
                    : Colors.grey,
              ),
              onPressed: dropdownPrice.value != null
                  ? () {
                      // Habilita el campo de edición si hay una promoción seleccionada
                      showCustomPriceDropdown.value =
                          !showCustomPriceDropdown.value;
                      customPriceController.text =
                          editPrice.value?.toString() ?? '';
                    }
                  : null, // Deshabilitar si no hay promoción seleccionada
            ),
          ],
        ),

        // TextField para editar el precio de la promoción seleccionada
        if (showCustomPriceDropdown.value)
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 32,
                child: TextField(
                  controller: customPriceController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newPrice = double.tryParse(value);
                    if (newPrice != null) {
                      editPrice.value =
                          newPrice; // Almacena el valor editado temporalmente
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 33,
                width: 110,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.secondaryColor,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    final price = double.tryParse(customPriceController.text);

                    if (price != null) {
                      // Aplicar el valor temporal editado al modelo del producto
                      ProductoEntity updatedProduct;

                      switch (dropdownPrice.value) {
                        case double value
                            when value == producto.precio4.toDouble():
                          updatedProduct =
                              producto.copyWith(precio4: price.toInt());
                          promociones.value[0] =
                              price; // Actualiza la lista de promociones
                          break;
                        case double value
                            when value == producto.precio5.toDouble():
                          updatedProduct =
                              producto.copyWith(precio5: price.toInt());
                          promociones.value[1] = price;
                          break;
                        case double value
                            when value == producto.precio6.toDouble():
                          updatedProduct =
                              producto.copyWith(precio6: price.toInt());
                          promociones.value[2] = price;
                          break;
                        case double value
                            when value == producto.precio7.toDouble():
                          updatedProduct =
                              producto.copyWith(precio7: price.toInt());
                          promociones.value[3] = price;
                          break;
                        case double value
                            when value == producto.precio8.toDouble():
                          updatedProduct =
                              producto.copyWith(precio8: price.toInt());
                          promociones.value[4] = price;
                          break;
                        case double value
                            when value == producto.precio9?.toDouble():
                          updatedProduct =
                              producto.copyWith(precio9: price.toInt());
                          promociones.value[5] = price;
                          break;
                        case double value
                            when value == producto.precio10?.toDouble():
                          updatedProduct =
                              producto.copyWith(precio10: price.toInt());
                          promociones.value[6] = price;
                          break;
                        default:
                          updatedProduct =
                              producto.copyWith(precio1: price.toInt());
                      }

                      // Enviar el evento para actualizar el producto en el bloc
                      context
                          .read<ProductosBloc>()
                          .add(UpdateProductEvent(updatedProduct));

                      // Actualiza el producto en la lista de productos locales
                      productos[index] = updatedProduct;

                      // Refrescar el total con el nuevo precio
                      updateTotal();

                      // Actualizar el `dropdownPrice` para reflejar el nuevo valor
                      dropdownPrice.value = price;
                      showCustomPriceDropdown.value = false;
                    }
                  },
                  child: const AutoSizeText(
                    'APLICAR PRECIO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colores.scaffoldBackgroundColor,
                    ),
                    minFontSize: 8,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<bool?> _dialogEliminar(BuildContext context, ProductoEntity producto) {
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
                context.read<ProductosBloc>().add(RemoveProductEvent(producto));
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
