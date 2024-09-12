import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/sesion/sesion_bloc.dart';
import 'package:sesion_ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class ListaDetalleProductos extends HookWidget {
  const ListaDetalleProductos({super.key, required this.productos});
  final List<DetalleSesionEntity> productos;

  @override
  Widget build(BuildContext context) {
    final total = useState<double>(0.0);

    final countList = useState<List<int>>(
        productos.map((p) => p.cantidad > 0 ? p.cantidad.toInt() : 1).toList());
    final selectedPriceList = useState<List<int>>(productos.map((p) {
      if (p.precio == p.precio1) {
        return 1;
      } else if (p.precio == p.precio2) {
        return 2;
      } else if (p.precio == p.precio3) {
        return 3;
      }
      return 1;
    }).toList());

    void updateTotal() {
      double newTotal = 0.0;
      UtilsVenta.listProductsOrder.clear();
      for (var i = 0; i < productos.length; i++) {
        if (i >= countList.value.length ||
            i >= selectedPriceList.value.length) {
          continue;
        }

        final count = countList.value[i];
        final selectedPrice = selectedPriceList.value[i];

        if (count > 0) {
          double precioUnitario = 0.0;
          switch (selectedPrice) {
            case 1:
              precioUnitario = productos[i].precio1.toDouble();
              break;
            case 2:
              precioUnitario = productos[i].precio2.toDouble();
              break;
            case 3:
              precioUnitario = productos[i].precio3.toDouble();
              break;
            default:
              break;
          }
          final subtotal = precioUnitario * count;
          newTotal += subtotal;
          UtilsVenta.listProductsOrder.add(
            DetallePedidoEntity(
              idPedido: 0,
              clave: productos[i].clave,
              clave2: productos[i].clave2,
              cantidad: count,
              precio: precioUnitario,
            ),
          );
        }
      }
      total.value = newTotal;
      UtilsVenta.total = total.value;
    }

    useEffect(() {
      updateTotal();
      return null;
    }, [countList.value, selectedPriceList.value]);

    useEffect(() {
      final newCountList = List<int>.from(countList.value);
      final newSelectedPriceList = List<int>.from(selectedPriceList.value);

      if (newCountList.length < productos.length) {
        newCountList.addAll(productos
            .sublist(newCountList.length)
            .map((p) => p.cantidad > 0 ? p.cantidad.toInt() : 1));
        newSelectedPriceList.addAll(List<int>.filled(
            productos.length - newSelectedPriceList.length, 1));
      } else if (newCountList.length > productos.length) {
        newCountList.removeRange(productos.length, newCountList.length);
        newSelectedPriceList.removeRange(
            productos.length, newSelectedPriceList.length);
      }

      countList.value = newCountList;
      selectedPriceList.value = newSelectedPriceList;
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
              final existencia = productos[index].bodega1 +
                  productos[index].bodega2 +
                  productos[index].bodega3 +
                  productos[index].bodega4;

              return HookBuilder(
                builder: (context) {
                  final count = useState(countList.value[index]);
                  final selectedPrice =
                      useState<int>(selectedPriceList.value[index]);
                  final customPrice = useState<double?>(null);
                  final customPriceController = useTextEditingController(
                      text: producto.precio3.toString());

                  return ClipRect(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      clipBehavior: Clip.hardEdge,
                      child: Dismissible(
                        key: Key(producto.producto1),
                        direction: DismissDirection.startToEnd,
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
                                  Image.network(
                                    'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
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
                                        label: 'Precio de Lista',
                                        price: producto.precio1.toDouble(),
                                        value: selectedPrice.value == 1,
                                        onChanged: (bool? value) {
                                          selectedPrice.value = 1;
                                          selectedPriceList.value[index] =
                                              selectedPrice.value;
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio de Expo',
                                        price: producto.precio2.toDouble(),
                                        value: selectedPrice.value == 2,
                                        onChanged: (bool? value) {
                                          selectedPrice.value = 2;
                                          selectedPriceList.value[index] =
                                              selectedPrice.value;
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio Mayoreo',
                                        price: producto.precio3.toDouble(),
                                        value: selectedPrice.value == 3,
                                        onChanged: (bool? value) {
                                          selectedPrice.value = 3;
                                          selectedPriceList.value[index] =
                                              selectedPrice.value;
                                          updateTotal();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (selectedPrice.value == 3)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
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
                                            selectedPriceList.value[index] =
                                                3; // Precio personalizado
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
                                                        precio3: price.toInt());
                                                context
                                                    .read<DetalleSesionBloc>()
                                                    .add(UpdateProductEvent(
                                                        updatedProduct));
                                                // Actualiza el producto en la lista
                                                productos[index] =
                                                    updatedProduct;
                                                // Refleja el nuevo precio en la lista de precios seleccionados
                                                selectedPriceList.value[index] =
                                                    3;
                                                updateTotal();
                                              }
                                            : null,
                                        child: const AutoSizeText(
                                          'APLICAR DESCUENTO',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colores
                                                  .scaffoldBackgroundColor),
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

  Future<bool?> _dialogEliminar(
      BuildContext context, DetalleSesionEntity producto) {
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
                    .read<DetalleSesionBloc>()
                    .add(RemoveProductEvent(producto));
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriceCheckbox({
    required BuildContext context,
    required String label,
    required double price,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Column(
      children: [
        AutoSizeText(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colores.secondaryColor,
            ),
            const SizedBox(width: 5),
            AutoSizeText(Utils.formatPrice(price),
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
