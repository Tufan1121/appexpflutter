import 'package:appexpflutter_update/features/punto_venta/domain/entities/producto_expo_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/punto_venta/utils.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/shipping_quote_modal_v2.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';
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
    final shippingCost = useState<double>(UtilsVenta.shippingCost);

    // Inicializa las listas con la longitud de productos, llenas de valores predeterminados
    final countList = useState<List<int>>(List.filled(productos.length, 1));
    final selectedPriceList =
        useState<List<int>>(List.filled(productos.length, 1));

    void updateTotal() {
      double newTotal = 0.0;
      UtilsVenta.listProductsOrder.clear();
      int totalItems = 0;

      for (var i = 0; i < productos.length; i++) {
        if (i >= countList.value.length ||
            i >= selectedPriceList.value.length) {
          continue; // Evita acceder fuera de los límites de las listas
        }

        final count = countList.value[i];
        final selectedPrice = selectedPriceList.value[i];

        if (count > 0) {
          totalItems += count;
          double precioUnitario = 0.0;
          switch (selectedPrice) {
            case 1:
              precioUnitario = productos[i].precio1.toDouble();
              break;
            case 2:
              precioUnitario = productos[i].precio2?.toDouble() ?? 0.0;
              break;
            default:
              break;
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
      }
      total.value = newTotal;
      UtilsVenta.total = total.value;
      
      // Forzar redraw
      shippingCost.value = UtilsVenta.shippingCost;
    }

    useEffect(() {
      updateTotal(); // Initial calculation
      return () {
        UtilsVenta.clearShipping();
      }; 
    }, [countList.value, selectedPriceList.value]);

    useEffect(() {
      // Actualizar countList y selectedPriceList cuando cambia la longitud de los productos
      final newCountList = List<int>.from(countList.value);
      final newSelectedPriceList = List<int>.from(selectedPriceList.value);

      // Ajusta la longitud de las listas
      if (newCountList.length < productos.length) {
        newCountList.addAll(
            List<int>.filled(productos.length - newCountList.length, 1));
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

    // Construye la lista de productos con dimensiones para cotización
    // Usa las dimensiones del producto y estima el peso basado en el área
    List<ProductShippingInfo> buildProductsForQuote() {
      final List<ProductShippingInfo> result = [];
      
      for (int i = 0; i < productos.length; i++) {
        if (i < countList.value.length && countList.value[i] > 0) {
          final producto = productos[i];
          
          // DEBUG: Imprimir valores originales del producto
          print('═══════════════════════════════════════════════════════════════');
          print('🔍 [PUNTO VENTA] buildProductsForQuote - Producto: ${producto.producto1}');
          print('   📦 Dimensiones de PAQUETE (largop/anchop/altop/pesoEnvio):');
          print('      largop: ${producto.largop}');
          print('      anchop: ${producto.anchop}');
          print('      altop: ${producto.altop}');
          print('      pesoEnvio: ${producto.pesoEnvio}');
          print('   📐 Dimensiones de PRODUCTO (largo/ancho en metros):');
          print('      largo: ${producto.largo}');
          print('      ancho: ${producto.ancho}');
          
          // Prioridad: usar dimensiones de paquete si existen, si no usar dimensiones del producto
          double largo;
          double ancho;
          double alto;
          double peso;
          
          // Si tenemos dimensiones de paquete del backend, usarlas
          if (producto.largop != null && producto.largop! > 0) {
            largo = producto.largop!;
          } else if (producto.largo != null && producto.largo! > 0) {
            // Convertir largo del producto de metros a cm
            largo = producto.largo! * 100;
          } else {
            largo = 30.0; // Valor por defecto
          }
          
          if (producto.anchop != null && producto.anchop! > 0) {
            ancho = producto.anchop!;
          } else if (producto.ancho != null && producto.ancho! > 0) {
            // Convertir ancho del producto de metros a cm
            ancho = producto.ancho! * 100;
          } else {
            ancho = 20.0; // Valor por defecto
          }
          
          if (producto.altop != null && producto.altop! > 0) {
            alto = producto.altop!;
          } else {
            // Estimar alto basado en si es un tapete enrollado (diámetro aprox)
            alto = 15.0; // Valor por defecto para tapete enrollado
          }
          
          if (producto.pesoEnvio != null && producto.pesoEnvio! > 0) {
            peso = producto.pesoEnvio!;
          } else {
            // Estimar peso basado en el área del producto (m2) * factor de peso por m2
            final area = ((producto.largo ?? 1.0) * (producto.ancho ?? 1.0));
            peso = area > 0 ? (area * 3.0).clamp(1.5, 50.0) : 2.0; // ~3kg por m2, mínimo 1.5kg, máximo 50kg
          }
          
          // DEBUG: Imprimir valores calculados
          print('   ✅ Valores USADOS para cotización:');
          print('      largo: $largo cm');
          print('      ancho: $ancho cm');
          print('      alto: $alto cm');
          print('      peso: $peso kg');
          print('═══════════════════════════════════════════════════════════════');
          
          result.add(ProductShippingInfo(
            productKey: producto.producto1,
            productName: producto.producto,
            largo: largo,
            ancho: ancho,
            alto: alto,
            peso: peso,
            cantidad: countList.value[i],
          ));
        }
      }
      return result;
    }

    return Column(
      children: [
        // Card de Totales y Envío
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:', style: GoogleFonts.inter(fontSize: 14)),
                    Text(Utils.formatPrice(total.value), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                         int totalCount = countList.value.fold(0, (sum, item) => sum + item);
                         if (totalCount == 0 && productos.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Agrega productos para cotizar envío')),
                           );
                           return;
                         }
                        
                         final productsForQuote = buildProductsForQuote();
                         
                         ShippingQuoteModalV2.show(
                           context: context,
                           products: productsForQuote,
                           onShippingSelected: (price, carrier, description, breakdown) {
                             UtilsVenta.setShipping(price, carrier, description, breakdown);
                             shippingCost.value = price;
                             updateTotal(); // Actualizar totales
                           },
                         );
                       },
                      icon: const Icon(Icons.local_shipping, size: 16, color: Colors.white),
                      label: const Text('Cotizar Envío', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    if (shippingCost.value > 0)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              UtilsVenta.shippingCarrier,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              Utils.formatPrice(shippingCost.value),
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () {
                                UtilsVenta.clearShipping();
                                shippingCost.value = 0;
                                updateTotal();
                              },
                              child: const Text('Eliminar envío', style: TextStyle(color: Colors.red, fontSize: 10)),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL:', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      Utils.formatPrice(total.value + shippingCost.value),
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colores.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final existencia = producto.hm;
              
              // Usar valores directos de las listas
              final currentCount = countList.value.length > index ? countList.value[index] : 1;
              final currentSelectedPrice = selectedPriceList.value.length > index ? selectedPriceList.value[index] : 1;

              return HookBuilder(
                builder: (context) {
                  final customPrice = useState<double?>(null);
                  final customPriceController = useTextEditingController(
                      text: producto.precio2.toString());
                  final scrollController = useScrollController(); // Scroll por item

                  return ClipRect(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      clipBehavior: Clip.hardEdge,
                      child: Dismissible(
                        direction: DismissDirection.startToEnd,
                        key: ValueKey('pv_${producto.producto1}'),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                          if (currentCount <
                                              existencia.toInt()) {
                                            countList.value[index] = currentCount + 1;
                                            updateTotal();
                                          } else {
                                             ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('No hay más existencia disponible'), duration: Duration(milliseconds: 1000)),
                                            );
                                          }
                                        },
                                      ),
                                      Text('$currentCount'),
                                      IconButton(
                                        icon: Icon(
                                          currentCount == 1 ? Icons.delete_outline : Icons.remove,
                                          color: currentCount == 1 ? Colors.red : null,
                                        ),
                                        onPressed: () async {
                                          if (currentCount > 1) {
                                            countList.value[index] = currentCount - 1;
                                            updateTotal();
                                          } else {
                                            // Eliminar
                                            final confirm = await _dialogEliminar(context, producto);
                                            // Si confirma, Dismissible lo maneja o estado se actualiza por el bloc
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Scrollbar(
                                controller: scrollController, // Usar controller unico por item
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio de Lista',
                                        price: producto.precio1.toDouble(),
                                        value: currentSelectedPrice == 1,
                                        onChanged: (bool? value) {
                                          selectedPriceList.value[index] = 1;
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio de Expo',
                                        price:
                                            producto.precio2?.toDouble() ?? 0.0,
                                        value: currentSelectedPrice == 2,
                                        onChanged: (bool? value) {
                                            selectedPriceList.value[index] = 2;
                                            updateTotal();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (currentSelectedPrice == 2)
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
                                             // Aquí solo actualizamos el precio localmente en la lógica
                                             // Pero la lógica actual depende del precio en el producto entity
                                             // Así que enviamos evento para actualizar producto en bloc
                                             
                                              final price = double.parse(customPriceController.text);
                                              final updatedProduct = producto.copyWith(precio2: price.toInt());
                                              context.read<ProductosTiendaBloc>().add(UpdateProductEvent(updatedProduct));
                                              // Se actualizará por el BlocListener padre
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
                                                        precio2: price.toInt());

                                                context
                                                    .read<ProductosTiendaBloc>()
                                                    .add(UpdateProductEvent(
                                                        updatedProduct));
                                                // La lista se reconstruirá cuando el estado del bloc cambie
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

