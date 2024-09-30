import 'package:appexpflutter_update/features/punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/detalle_pedido_entity.dart';
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

    void updateTotal() {
      double newTotal = 0.0;
      UtilsVenta.listProductsOrder.clear();
      for (var i = 0; i < productos.length; i++) {
        if (i >= countList.value.length || i >= customPriceList.value.length) {
          continue; // Evita acceder fuera de los límites de las listas
        }

        final count = countList.value[i];
        final customPrice = customPriceList.value[i];
        double precioUnitario = customPrice ?? productos[i].precio1.toDouble();
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
      updateTotal(); // Initial calculation
      return null; // No cleanup needed
    }, [countList.value, customPriceList.value]);

    useEffect(() {
      // Actualizar countList y customPriceList cuando cambia la longitud de los productos
      final newCountList = List<int>.from(countList.value);
      final newCustomPriceList = List<double?>.from(customPriceList.value);

      // Ajusta la longitud de las listas
      if (newCountList.length < productos.length) {
        newCountList.addAll(
            List<int>.filled(productos.length - newCountList.length, 1));
        newCustomPriceList.addAll(List<double?>.filled(
            productos.length - newCustomPriceList.length, null));
      } else if (newCountList.length > productos.length) {
        newCountList.removeRange(productos.length, newCountList.length);
        newCustomPriceList.removeRange(
            productos.length, newCustomPriceList.length);
      }

      countList.value = newCountList;
      customPriceList.value = newCustomPriceList;
      updateTotal();
      return null;
    }, [productos.length]);

    return Column(
      children: [
        Text('Total: ${Utils.formatPrice(total.value)}',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colores.scaffoldBackgroundColor,
                shadows: [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2.0, 5.0),
                  )
                ])),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.66,
          child: ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final existencia = producto.hm;
              return HookBuilder(
                builder: (context) {
                  final count = useState(countList.value[index]);
                  final showCustomPrice = useState<bool>(false);
                  final customPrice =
                      useState<double?>(customPriceList.value[index]);
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
                          child: const Icon(Icons.delete, color: Colors.white),
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
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Existencia: ${existencia.toInt()}',
                                          style: const TextStyle(fontSize: 14),
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
                                        label: 'Precio Expo',
                                        price: producto.precio1.toDouble(),
                                        value: showCustomPrice.value,
                                        onChanged: (bool? value) {
                                          showCustomPrice.value =
                                              value ?? false;
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
                                        onSubmitted: (value) {
                                          if (customPrice.value != null) {
                                            customPriceList.value[index] =
                                                customPrice.value;
                                            updateTotal();
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
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
                                                Colores.secondaryColor),
                                        onPressed: customPrice.value != null
                                            ? () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                final price = double.parse(
                                                    customPriceController.text);

                                                final updatedProduct =
                                                    producto.copyWith(
                                                        precio1: price.toInt());

                                                context
                                                    .read<ProductosTiendaBloc>()
                                                    .add(UpdateProductEvent(
                                                        updatedProduct));
                                                // Actualiza el producto en la lista
                                                productos[index] =
                                                    updatedProduct;

                                                updateTotal();
                                              }
                                            : null,
                                        child: const AutoSizeText(
                                          'APLICAR PRECIO',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colores
                                                  .scaffoldBackgroundColor),
                                          // maxLines: 1,
                                          minFontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ],
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
          actions: <Widget>[
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
