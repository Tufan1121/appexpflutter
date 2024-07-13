import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class ListaDetalleProductos extends HookWidget {
  const ListaDetalleProductos({super.key, required this.detalleProductos});
  final List<DetalleSesionEntity> detalleProductos;

  @override
  Widget build(BuildContext context) {
    final total = useState<double>(0.0);

    // Inicializa las listas con la longitud de productos, llenas de valores predeterminados
    final countList =
        useState<List<int>>(List.filled(detalleProductos.length, 1));
    final selectedPriceList =
        useState<List<int>>(List.filled(detalleProductos.length, 1));

    void updateTotal() {
      double newTotal = 0.0;
      UtilsVenta.listProductsOrder.clear();
      for (var i = 0; i < detalleProductos.length; i++) {
        if (i >= countList.value.length ||
            i >= selectedPriceList.value.length) {
          continue; // Evita acceder fuera de los límites de las listas
        }

        // final count = countList.value[i];
        final count = detalleProductos[i].cantidad.toInt();
        // final selectedPrice = selectedPriceList.value[i];
        // print('Producto ${productos[i].producto}: count = $count, selectedPrice = $selectedPrice');

        if (count > 0) {
          double precioUnitario = 0.0;
          precioUnitario = detalleProductos[i].precio.toDouble();
          // switch (selectedPrice) {
          //   case 1:
          //     precioUnitario = detalleProductos[i].precio.toDouble();
          //     break;
          //   case 2:
          //     precioUnitario = detalleProductos[i].precio2.toDouble();
          //     break;
          //   case 3:
          //     precioUnitario = detalleProductos[i].precio3.toDouble();
          //     break;
          //   default:
          //     break;
          // }
          final subtotal = precioUnitario * count;
          newTotal += subtotal;
          UtilsVenta.listProductsOrder.add(
            DetallePedidoEntity(
              idPedido: 0,
              clave: detalleProductos[i].clave,
              clave2: detalleProductos[i].clave2,
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
      updateTotal(); // Initial calculation
      return null; // No cleanup needed
    }, [countList.value, selectedPriceList.value]);

    useEffect(() {
      // Actualizar countList y selectedPriceList cuando cambia la longitud de los productos
      final newCountList = List<int>.from(countList.value);
      final newSelectedPriceList = List<int>.from(selectedPriceList.value);

      // Ajusta la longitud de las listas
      if (newCountList.length < detalleProductos.length) {
        newCountList.addAll(
            List<int>.filled(detalleProductos.length - newCountList.length, 1));
        newSelectedPriceList.addAll(List<int>.filled(
            detalleProductos.length - newSelectedPriceList.length, 1));
      } else if (newCountList.length > detalleProductos.length) {
        newCountList.removeRange(detalleProductos.length, newCountList.length);
        newSelectedPriceList.removeRange(
            detalleProductos.length, newSelectedPriceList.length);
      }

      countList.value = newCountList;
      selectedPriceList.value = newSelectedPriceList;
      updateTotal();
      return null;
    }, [detalleProductos.length]);

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
            itemCount: detalleProductos.length,
            itemBuilder: (context, index) {
              final producto = detalleProductos[index];
              // final existencia = detalleProductos[index].bodega1 +
              //     detalleProductos[index].bodega2 +
              //     detalleProductos[index].bodega3 +
              //     detalleProductos[index].bodega4;

              return HookBuilder(
                builder: (context) {
                  // final count = useState(countList.value[index]);
                  final selectedPrice =
                      useState<int>(selectedPriceList.value[index]);
                  // final customPrice = useState<double?>(null);
                  // final customPriceController = useTextEditingController(
                  //     text: producto.precio.toString());

                  return ClipRect(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      clipBehavior: Clip.hardEdge,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Image.network(
                                //   'https://tapetestufan.mx:446/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
                                //   width: 60,
                                //   height: 60,
                                //   fit: BoxFit.cover,
                                // ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        producto.clave2,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      AutoSizeText(
                                        'Clave: ${producto.clave}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      AutoSizeText(
                                        'Pedidos: ${producto.pedidos}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Row(
                                  children: [
                                    const AutoSizeText('Cantidad: ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 2),
                                    Text('${producto.cantidad.toInt()}'),
                                  ],
                                ),
                                // Row(
                                //   children: [
                                //     IconButton(
                                //       icon: const Icon(Icons.add),
                                //       onPressed: () {
                                //         if (count.value <
                                //             existencia.toInt()) {
                                //           count.value++;
                                //           countList.value[index] =
                                //               count.value;
                                //           updateTotal();
                                //         }
                                //       },
                                //     ),
                                //     Text('${count.value}'),
                                //     IconButton(
                                //       icon: const Icon(Icons.remove),
                                //       onPressed: () {
                                //         if (count.value > 1) {
                                //           count.value--;
                                //           countList.value[index] =
                                //               count.value;
                                //           updateTotal();
                                //         }
                                //       },
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            _buildPriceCheckbox(
                              context: context,
                              label: 'Precio',
                              price: producto.precio.toDouble(),
                              value: selectedPrice.value == 1,
                              onChanged: (bool? value) {
                                selectedPrice.value = 1;
                                selectedPriceList.value[index] =
                                    selectedPrice.value;
                                updateTotal();
                              },
                            ),
                          ],
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
    required Function(bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(width: 2),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colores.secondaryColor,
            ),
            const SizedBox(width: 5),
            AutoSizeText(Utils.formatPrice(price),
                style: const TextStyle(fontSize: 15)),
          ],
        ),
      ],
    );
  }
}
