import 'dart:async';

import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/config/primera_mayuscula_formatter.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/shared/widgets/descuento_dialog.dart';
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
    // Se incrementa al cambiar una cantidad, un precio o el envío: obliga a
    // reconstruir y, con ello, a recalcular el total y el detalle.
    final revision = useState<int>(0);

    // Las cantidades y los precios viven en UtilsVenta indexados por clave, no
    // en hooks locales: el bloc emite ProductoLoading cada vez que se escanea
    // un producto, lo que desmonta este widget y borraba el estado local
    // (todo volvía a cantidad 1 y a "Precio de Lista", el más caro). Además,
    // al quitar un producto intermedio las posiciones se recorrían y la
    // cantidad/precio terminaban aplicados al producto equivocado.

    double precioUnitarioDe(ProductoEntity producto) {
      switch (UtilsVenta.precioSeleccionadoDe(producto.producto1)) {
        case 2:
          return producto.precio2.toDouble();
        case 3:
          return producto.precio3.toDouble();
        default:
          return producto.precio1.toDouble();
      }
    }

    // El total y el detalle que se manda al backend se calculan en cada build a
    // partir de lo que está en pantalla: nunca pueden quedar desfasados.
    // totalBase: sin descuentos. subtotalConPartidas: solo descuentos por
    // partida (base para convertir un monto general a %). total: final.
    double totalBase = 0.0;
    double subtotalConPartidas = 0.0;
    double total = 0.0;
    UtilsVenta.listProductsOrder.clear();
    for (final producto in productos) {
      final clave = producto.producto1;
      final cantidad = UtilsVenta.cantidadDe(clave);
      final precioBase = precioUnitarioDe(producto);
      final precioUnitario = UtilsVenta.aplicarDescuentos(clave, precioBase);
      totalBase += precioBase * cantidad;
      subtotalConPartidas +=
          precioBase * (1 - UtilsVenta.descuentoDe(clave) / 100) * cantidad;
      total += precioUnitario * cantidad;
      UtilsVenta.listProductsOrder.add(
        DetallePedidoEntity(
          idPedido: 0,
          clave: clave,
          clave2: producto.producto,
          cantidad: cantidad,
          precio: precioUnitario,
          observa: UtilsVenta.observaDe(clave),
        ),
      );
    }
    UtilsVenta.total = total;

    final shippingCost = UtilsVenta.shippingCost;

    // Fuerza un nuevo build (y con él, el recálculo de arriba).
    void updateTotal() => revision.value++;

    // Descuento general autorizado: se captura por % o por monto y el
    // prorrateo entre partidas es automático.
    Future<void> abrirDialogoDescuento() async {
      final resultado = await mostrarDialogoDescuento(
        context,
        subtotalActual: subtotalConPartidas,
        descuentoActualPct: UtilsVenta.descuentoGeneral,
      );
      if (resultado == null || !context.mounted) return;
      UtilsVenta.descuentoGeneral = resultado.quitar ? 0 : resultado.porcentaje;
      updateTotal();
    }

    // Calcula el número total de productos (cantidad)
    int totalProductCount() {
      int count = 0;
      for (final producto in productos) {
        count += UtilsVenta.cantidadDe(producto.producto1);
      }
      return count;
    }

    // Construye la lista de productos con dimensiones para cotización
    List<ProductShippingInfo> buildProductsForQuote() {
      final List<ProductShippingInfo> result = [];
      for (final producto in productos) {
        {
          
          // DEBUG: Imprimir valores originales del producto
          print('═══════════════════════════════════════════════════════════════');
          print('🔍 [VENTAS] buildProductsForQuote - Producto: ${producto.producto1}');
          print('   📦 Dimensiones de PAQUETE (largop/anchop/altop/peso):');
          print('      largop: ${producto.largop}');
          print('      anchop: ${producto.anchop}');
          print('      altop: ${producto.altop}');
          print('      peso: ${producto.peso}');
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
          } else if (producto.largo > 0) {
            // Convertir largo del producto de metros a cm
            largo = producto.largo * 100;
          } else {
            largo = 30.0; // Valor por defecto
          }
          
          if (producto.anchop != null && producto.anchop! > 0) {
            ancho = producto.anchop!;
          } else if (producto.ancho > 0) {
            // Convertir ancho del producto de metros a cm
            ancho = producto.ancho * 100;
          } else {
            ancho = 20.0; // Valor por defecto
          }
          
          if (producto.altop != null && producto.altop! > 0) {
            alto = producto.altop!;
          } else {
            // Estimar alto basado en si es un tapete enrollado (diámetro aprox)
            alto = 15.0; // Valor por defecto para tapete enrollado
          }
          
          if (producto.peso != null && producto.peso! > 0) {
            peso = producto.peso!;
          } else {
            // Estimar peso basado en el área del producto (m2) * factor de peso por m2
            final area = producto.largo * producto.ancho;
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
            cantidad: UtilsVenta.cantidadDe(producto.producto1),
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
                    Utils.formatPrice(totalBase),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colores.textPrimary,
                    ),
                  ),
                ],
              ),
              // Descuento general: área resaltada para que no pase
              // desapercibida entre los totales.
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colores.secondaryColor
                      .withOpacity(UtilsVenta.descuentoGeneral > 0 ? 0.14 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colores.secondaryColor.withOpacity(0.5),
                    width: UtilsVenta.descuentoGeneral > 0 ? 1.4 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: abrirDialogoDescuento,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.percent,
                              size: 16, color: Colores.secondaryColor),
                          const SizedBox(width: 6),
                          Text(
                            UtilsVenta.descuentoGeneral > 0
                                ? 'Descuento general: ${UtilsVenta.descuentoGeneral.toStringAsFixed(2)}%'
                                : 'Aplicar descuento',
                            style: const TextStyle(
                                color: Colores.secondaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      if (UtilsVenta.hayDescuento)
                        Text(
                          '-${Utils.formatPrice(totalBase - total)}',
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                      else
                        const Icon(Icons.chevron_right,
                            size: 18, color: Colores.secondaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Botón de cotizar envío / Envío seleccionado
              if (shippingCost > 0) ...[
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
                        Utils.formatPrice(shippingCost),
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
                          updateTotal();
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
                        updateTotal(); // Recalcular totales con envío
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
                    Utils.formatPrice(total + shippingCost),
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

              // Cantidad y precio se leen por clave, nunca por posición.
              final clave = producto.producto1;
              
              return HookBuilder(
                key: ValueKey(producto.producto1), // Key movido aquí
                builder: (context) {
                  final currentCount = UtilsVenta.cantidadDe(clave);
                  final currentSelectedPrice =
                      UtilsVenta.precioSeleccionadoDe(clave);
                  
                  final customPrice = useState<double?>(null);
                  final customPriceController = useTextEditingController(
                      text: producto.precio3.toString());
                  final descuentoController = useTextEditingController(
                      text: UtilsVenta.descuentoDe(clave) > 0
                          ? UtilsVenta.descuentoDe(clave).toString()
                          : '');
                  final observaController = useTextEditingController(
                      text: UtilsVenta.observaDe(clave));

                  // El precio de mayoreo se aplica solo, sin botón: el usuario
                  // olvidaba presionar APLICAR y el pedido salía con el precio
                  // anterior. El debounce evita aplicar números a medio teclear.
                  final debouncePrecio = useRef<Timer?>(null);
                  useEffect(() => () => debouncePrecio.value?.cancel(), []);

                  void aplicarPrecio() {
                    final price = customPrice.value;
                    if (price == null || price <= 0) return;
                    if (price.round() == producto.precio3) return;
                    context.read<ProductosBloc>().add(UpdateProductEvent(
                        producto.copyWith(precio3: price.round())));
                    UtilsVenta.setPrecioSeleccionado(clave, 3);
                    updateTotal();
                  }

                  void aplicarPrecioDespues() {
                    debouncePrecio.value?.cancel();
                    debouncePrecio.value =
                        Timer(const Duration(milliseconds: 600), () {
                      if (context.mounted) aplicarPrecio();
                    });
                  }

                  void aplicarPrecioAhora() {
                    debouncePrecio.value?.cancel();
                    aplicarPrecio();
                  }

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
                                    'https://tapetestufan.mx/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
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
                                            UtilsVenta.setCantidad(clave, currentCount + 1);
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
                                            UtilsVenta.setCantidad(clave, currentCount - 1);
                                            updateTotal();
                                          } else {
                                            // El bloc quita el producto y
                                            // olvidar() descarta su selección.
                                            await _dialogEliminar(context, producto);
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
                                          UtilsVenta.setPrecioSeleccionado(clave, 1);
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio de Expo',
                                        price: producto.precio2.toDouble(),
                                        value: currentSelectedPrice == 2,
                                        onChanged: (bool? value) {
                                          UtilsVenta.setPrecioSeleccionado(clave, 2);
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio Mayoreo',
                                        price: producto.precio3.toDouble(),
                                        value: currentSelectedPrice == 3,
                                        onChanged: (bool? value) {
                                          UtilsVenta.setPrecioSeleccionado(clave, 3);
                                          updateTotal();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Descuento autorizado por partida: área
                              // resaltada; el % se captura y el precio se
                              // recalcula solo, sin cuentas a mano.
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colores.secondaryColor.withOpacity(
                                      UtilsVenta.descuentoDe(clave) > 0
                                          ? 0.12
                                          : 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colores.secondaryColor
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.local_offer,
                                        size: 13,
                                        color: Colores.secondaryColor),
                                    const SizedBox(width: 4),
                                    const Text('Desc. partida:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colores.secondaryColor)),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 62,
                                      height: 28,
                                      child: TextField(
                                        controller: descuentoController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        onChanged: (value) {
                                          final pct =
                                              double.tryParse(value) ?? 0;
                                          UtilsVenta.setDescuento(clave,
                                              pct.clamp(0, 100).toDouble());
                                          updateTotal();
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          suffixText: '%',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                        ),
                                      ),
                                    ),
                                    if (UtilsVenta.descuentoDe(clave) > 0 ||
                                        UtilsVenta.descuentoGeneral > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'c/desc: ${Utils.formatPrice(UtilsVenta.aplicarDescuentos(clave, precioUnitarioDe(producto)))}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Observaciones opcionales de la partida; viajan
                              // en la columna `observa` del detalle.
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextField(
                                  controller: observaController,
                                  maxLength: 250,
                                  minLines: 1,
                                  maxLines: 2,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  // Garantiza la primera letra en mayúscula
                                  // (sentences solo lo sugiere en el teclado).
                                  inputFormatters: const [
                                    PrimeraMayusculaFormatter(),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF37474F),
                                    height: 1.3,
                                  ),
                                  onChanged: (value) {
                                    UtilsVenta.setObserva(clave, value);
                                    updateTotal();
                                  },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: const Color(0xFFF6F7FB),
                                    prefixIcon: const Icon(Icons.edit_note,
                                        size: 20, color: Colors.blueGrey),
                                    prefixIconConstraints:
                                        const BoxConstraints(
                                            minWidth: 34, minHeight: 0),
                                    labelText:
                                        'Observaciones de la partida (opcional)',
                                    labelStyle: const TextStyle(
                                        fontSize: 11.5,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blueGrey),
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey.shade100),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey.shade100),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colores.secondaryColor,
                                          width: 1.4),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),
                              if (currentSelectedPrice == 3)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Precio manual (se aplica automáticamente)',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 90,
                                      height: 32,
                                      child: TextField(
                                        controller: customPriceController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          customPrice.value =
                                              double.tryParse(value);
                                          aplicarPrecioDespues();
                                        },
                                        onSubmitted: (_) =>
                                            aplicarPrecioAhora(),
                                        onTapOutside: (_) {
                                          aplicarPrecioAhora();
                                          FocusScope.of(context).unfocus();
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
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
