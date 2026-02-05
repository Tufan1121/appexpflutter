import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/widgets/shipping_quote_modal_v2.dart';
import 'package:appexpflutter_update/features/cotizador_envio/data/models/product_shipping_info.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appexpflutter_update/config/utils/utils.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/precios/domain/entities/producto_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';

class ListaProductos extends HookWidget {
  const ListaProductos({super.key, required this.productos});
  final List<ProductoEntity> productos;

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
      for (var i = 0; i < productos.length; i++) {
        if (i >= countList.value.length ||
            i >= selectedPriceList.value.length) {
          continue; // Evita acceder fuera de los límites de las listas
        }

        final count = countList.value[i];
        final selectedPrice = selectedPriceList.value[i];
        // print('Producto ${productos[i].producto}: count = $count, selectedPrice = $selectedPrice');

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

    // Calcula el número total de productos (cantidad)
    int totalProductCount() {
      int count = 0;
      for (int i = 0; i < productos.length; i++) {
        if (i < countList.value.length) {
          count += countList.value[i];
        }
      }
      return count;
    }

    // Construye la lista de productos con dimensiones para cotización
    List<ProductShippingInfo> buildProductsForQuote() {
      final List<ProductShippingInfo> result = [];
      for (int i = 0; i < productos.length; i++) {
        if (i < countList.value.length && countList.value[i] > 0) {
          final producto = productos[i];
          
          // DEBUG: Imprimir valores originales del producto
          print('═══════════════════════════════════════════════════════════════');
          print('🔍 [VENTAS] buildProductsForQuote - Producto: ${producto.producto1}');
          print('   📦 Dimensiones de PAQUETE (largop/anchop/altop/peso):');
          print('      largop: ${producto.largop}');
          print('      anchop: ${producto.anchop}');
          print('      altop: ${producto.altop}');
          print('      peso: ${producto.peso}');
          print('   📐 Dimensiones de PRODUCTO (largo/ancho):');
          print('      largo: ${producto.largo}');
          print('      ancho: ${producto.ancho}');
          
          // Usar dimensiones de paquete del backend si están disponibles (largop, anchop, altop, peso)
          // Si no están disponibles, usar fallback basado en medidas del producto
          final double largo = producto.largop ?? (producto.largo > 0 ? producto.largo * 100 : 30); // convertir m a cm si es medida de producto
          final double ancho = producto.anchop ?? (producto.ancho > 0 ? producto.ancho * 100 : 20);
          final double alto = producto.altop ?? 10.0; // Alto estimado por defecto si no viene del backend
          final double peso = producto.peso ?? 1.5; // Peso estimado por defecto si no viene del backend
          
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
        // Card con totales y botón de envío
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Subtotal de productos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal (${productos.length} producto${productos.length != 1 ? 's' : ''}):',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colores.textSecondary,
                    ),
                  ),
                  Text(
                    Utils.formatPrice(total.value),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colores.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Botón de cotizar envío / Envío seleccionado
              if (shippingCost.value > 0) ...[
                // Mostrar envío seleccionado
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colores.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colores.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_rounded,
                        color: Colores.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Envío: ${UtilsVenta.shippingCarrier}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colores.textPrimary,
                              ),
                            ),
                            Text(
                              UtilsVenta.shippingServiceDescription,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                color: Colores.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Utils.formatPrice(shippingCost.value),
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colores.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Botón para cambiar o quitar envío
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: Colores.textSecondary,
                        onPressed: () {
                          UtilsVenta.clearShipping();
                          shippingCost.value = 0;
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Botón para cotizar envío
                InkWell(
                  onTap: () {
                    if (productos.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agrega productos al pedido primero'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    final productsForQuote = buildProductsForQuote();
                    ShippingQuoteModalV2.show(
                      context: context,
                      products: productsForQuote,
                      onShippingSelected: (price, carrier, description, breakdown) {
                        UtilsVenta.setShipping(
                          cost: price,
                          carrier: carrier,
                          serviceDescription: description,
                          breakdown: breakdown,
                        );
                        shippingCost.value = price;
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colores.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colores.secondaryColor.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          color: Colores.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cotizar Envío',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colores.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colores.secondaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              
              // Total general
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL:',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colores.textPrimary,
                    ),
                  ),
                  Text(
                    Utils.formatPrice(total.value + shippingCost.value),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colores.secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            // Importante: Usar key en el item para que Flutter mantenga el estado correcto al eliminar
            itemBuilder: (context, index) {
              final producto = productos[index];
              final existencia = productos[index].bodega1 +
                  productos[index].bodega2 +
                  productos[index].bodega3 +
                  productos[index].bodega4;

              // Eliminamos el useState local para evitar desincronización
              // Leemos y escribimos directamente en las listas del padre
              
              return HookBuilder(
                key: ValueKey(producto.producto1), // Key movido aquí
                builder: (context) {
                  // Leemos el valor actual directamente de la lista
                  final currentCount = countList.value[index];
                  final currentSelectedPrice = selectedPriceList.value[index];
                  
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
                        direction: DismissDirection.startToEnd,
                        key: ValueKey('dismiss_${producto.producto1}'), // Key distinta para dismiss
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
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, size: 60),
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
                                          if (currentCount < existencia.toInt()) {
                                            // Actualizamos la lista directamente
                                            countList.value[index] = currentCount + 1;
                                            updateTotal(); // Esto forzará rebuild
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
                                            updateTotal(); // Esto forzará rebuild
                                          } else {
                                            // Si count == 1, confirmar eliminación
                                            final confirmar = await _dialogEliminar(context, producto);
                                            if (confirmar == true) {
                                              // El producto será eliminado por el Dismissible/Bloc
                                              // No necesitamos hacer nada más aquí
                                            }
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
                                        value: currentSelectedPrice == 1,
                                        onChanged: (bool? value) {
                                          selectedPriceList.value[index] = 1;
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio de Expo',
                                        price: producto.precio2.toDouble(),
                                        value: currentSelectedPrice == 2,
                                        onChanged: (bool? value) {
                                          selectedPriceList.value[index] = 2;
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio Mayoreo',
                                        price: producto.precio3.toDouble(),
                                        value: currentSelectedPrice == 3,
                                        onChanged: (bool? value) {
                                          selectedPriceList.value[index] = 3;
                                          updateTotal();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (currentSelectedPrice == 3)
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
                                            selectedPriceList.value[index] = 3;
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
                                                    .read<ProductosBloc>()
                                                    .add(UpdateProductEvent(
                                                        updatedProduct));

                                                // Actualiza el producto en la lista original (referencia)
                                                // Nota: Esto no persiste si el padre no se actualiza, pero aquí es suficiente
                                                productos[index] = updatedProduct;
                                                selectedPriceList.value[index] = 3;
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
