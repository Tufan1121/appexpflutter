import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/config/utils.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/producto/productos_bloc.dart';

class ListaProductos extends HookWidget {
  const ListaProductos({super.key, required this.productos});
  final List<ProductoEntity> productos;

  @override
  Widget build(BuildContext context) {
    final total = useState<double>(0.0);
    final countList =
        useState<List<int>>(List<int>.filled(productos.length, 1));

    final selectedPriceList =
        useState<List<int?>>(List<int?>.filled(productos.length, 1));

    void updateTotal() {
      double newTotal = 0.0;
      for (var i = 0; i < productos.length; i++) {
        final count = countList.value[i];
        final selectedPrice = selectedPriceList.value[i];
        if (count > 0) {
          switch (selectedPrice) {
            case 1:
              newTotal += productos[i].precio1 * count;
              break;
            case 2:
              newTotal += productos[i].precio2 * count;
              break;
            case 3:
              newTotal += productos[i].precio3 * count;
              break;
            default:
              break;
          }
        }
        UtilsVenta.listProductsOrder.add(
          DetallePedido(
              idPedido: 0,
              clave: productos[i].producto1,
              clave2: productos[i].producto,
              cantidad: count,
              precio: newTotal),
        );
      }
      total.value = newTotal;
      UtilsVenta.total = total.value;
    }

    useEffect(() {
      updateTotal(); // Initial calculation
      return null; // No cleanup needed
    }, [countList.value, selectedPriceList.value]);
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
          height: MediaQuery.of(context).size.height * 0.67,
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
                  final count = useState(1);
                  final selectedPrice = useState<int>(1);
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
                        onDismissed: (direction) {
                          context
                              .read<ProductosBloc>()
                              .add(RemoveProductEvent(producto));
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
                                          selectedPrice.value = selectedPrice
                                              .value = value! ? 1 : 0;
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
                                          selectedPrice.value = selectedPrice
                                              .value = value! ? 2 : 0;
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
                                          selectedPrice.value = selectedPrice
                                              .value = value! ? 3 : 0;
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
                                      width: 50,
                                      height: 50,
                                      child: TextField(
                                        decoration: const InputDecoration(),
                                        style: const TextStyle(fontSize: 15),
                                        inputFormatters: const [],
                                        controller: customPriceController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          customPrice.value =
                                              double.tryParse(value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      height: 33,
                                      width: 110,
                                      child: ElevatedButton(
                                        onPressed: customPrice.value != null
                                            ? () {
                                                final price = double.parse(
                                                    customPriceController.text);
                                                final updatedProduct =
                                                    producto.copyWith(
                                                        precio3: price.toInt());
                                                context
                                                    .read<ProductosBloc>()
                                                    .add(UpdateProductEvent(
                                                        updatedProduct));
                                                updateTotal();
                                              }
                                            : null,
                                        child: const AutoSizeText(
                                          'Aplicar descuento',
                                          style: TextStyle(fontSize: 2),
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
    required void Function(bool?) onChanged,
  }) {
    return Column(
      children: [
        AutoSizeText(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: Colores.secondaryColor),
            AutoSizeText(
              Utils.formatPrice(price),
              maxLines: 2,
            ),
          ],
        ),
      ],
    );
  }
}
