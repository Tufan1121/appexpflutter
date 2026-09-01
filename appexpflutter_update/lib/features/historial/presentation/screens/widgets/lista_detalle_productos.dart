import 'dart:async';

import 'package:appexpflutter_update/features/historial/domain/entities/detalle_sesion_entity.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/sesion/sesion_bloc.dart';
import 'package:appexpflutter_update/features/ventas/domain/entities/detalle_pedido_entity.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/utils.dart';
import 'package:appexpflutter_update/features/shared/widgets/descuento_dialog.dart';
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
    // Se incrementa al cambiar una cantidad o un precio: obliga a reconstruir
    // y, con ello, a recalcular el total y el detalle.
    final revision = useState<int>(0);

    // Cantidades y precios indexados por clave, no por posición: al quitar un
    // producto intermedio las posiciones se recorrían y la cantidad/precio
    // terminaban aplicados al producto equivocado.
    for (final producto in productos) {
      final clave = producto.producto1;
      UtilsVenta.cantidades.putIfAbsent(
          clave, () => producto.cantidad > 0 ? producto.cantidad.toInt() : 1);
      UtilsVenta.preciosSeleccionados.putIfAbsent(clave, () {
        if (producto.precio == producto.precio2) return 2;
        if (producto.precio == producto.precio3) return 3;
        return 1;
      });
    }

    double precioUnitarioDe(DetalleSesionEntity producto) {
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
    // partida (base para convertir un monto general a %). totalValue: final.
    double totalBase = 0.0;
    double subtotalConPartidas = 0.0;
    double totalValue = 0.0;
    UtilsVenta.listProductsOrder.clear();
    for (final producto in productos) {
      final clave = producto.producto1;
      final cantidad = UtilsVenta.cantidadDe(clave);
      final precioBase = precioUnitarioDe(producto);
      final precioUnitario = UtilsVenta.aplicarDescuentos(clave, precioBase);
      totalBase += precioBase * cantidad;
      subtotalConPartidas +=
          precioBase * (1 - UtilsVenta.descuentoDe(clave) / 100) * cantidad;
      totalValue += precioUnitario * cantidad;
      UtilsVenta.listProductsOrder.add(
        DetallePedidoEntity(
          idPedido: 0,
          clave: producto.clave,
          clave2: producto.clave2,
          cantidad: cantidad,
          precio: precioUnitario,
          // La observación se captura indexada por producto1 (la misma clave
          // que cantidades y descuentos).
          observa: UtilsVenta.observaDe(clave),
        ),
      );
    }
    UtilsVenta.total = totalValue;

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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Total: ${Utils.formatPrice(totalValue + UtilsVenta.shippingCost)}',
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
            const SizedBox(width: 8),
            // Descuento general autorizado
            InkWell(
              onTap: abrirDialogoDescuento,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colores.scaffoldBackgroundColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  UtilsVenta.descuentoGeneral > 0
                      ? '-${UtilsVenta.descuentoGeneral.toStringAsFixed(2)}%'
                      : '% Desc.',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colores.secondaryColor),
                ),
              ),
            ),
          ],
        ),
        if (UtilsVenta.hayDescuento)
          Text(
            'Descuento: -${Utils.formatPrice(totalBase - totalValue)}',
            style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent),
          ),
        if (UtilsVenta.hasShipping)
          Text(
            'Incluye envío: ${Utils.formatPrice(UtilsVenta.shippingCost)}',
            style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colores.scaffoldBackgroundColor),
          ),
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

              // Cantidad y precio se leen por clave, nunca por posición.
              final clave = producto.producto1;

              return HookBuilder(
                key: ValueKey('sesion_$clave'),
                builder: (context) {
                  final count = UtilsVenta.cantidadDe(clave);
                  final selectedPrice = UtilsVenta.precioSeleccionadoDe(clave);
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
                    context.read<DetalleSesionBloc>().add(UpdateProductEvent(
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
                                    'https://tapetestufan.mx/imagen/_web/${Uri.encodeFull(producto.pathima1)}',
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
                                          if (count < existencia.toInt()) {
                                            UtilsVenta.setCantidad(clave, count + 1);
                                            updateTotal();
                                          }
                                        },
                                      ),
                                      Text('$count'),
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (count > 1) {
                                            UtilsVenta.setCantidad(
                                                clave, count - 1);
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
                                        value: selectedPrice == 1,
                                        onChanged: (bool? value) {
                                          UtilsVenta.setPrecioSeleccionado(clave, 1);
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio de Expo',
                                        price: producto.precio2.toDouble(),
                                        value: selectedPrice == 2,
                                        onChanged: (bool? value) {
                                          UtilsVenta.setPrecioSeleccionado(clave, 2);
                                          updateTotal();
                                        },
                                      ),
                                      _buildPriceCheckbox(
                                        context: context,
                                        label: 'Precio Mayoreo',
                                        price: producto.precio3.toDouble(),
                                        value: selectedPrice == 3,
                                        onChanged: (bool? value) {
                                          UtilsVenta.setPrecioSeleccionado(clave, 3);
                                          updateTotal();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Descuento autorizado por partida: se captura el
                              // % y el precio se recalcula solo, sin cuentas a
                              // mano.
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Desc. partida:',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 62,
                                    height: 28,
                                    child: TextField(
                                      controller: descuentoController,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(decimal: true),
                                      style: const TextStyle(fontSize: 12),
                                      onChanged: (value) {
                                        final pct =
                                            double.tryParse(value) ?? 0;
                                        UtilsVenta.setDescuento(clave,
                                            pct.clamp(0, 100).toDouble());
                                        updateTotal();
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        suffixText: '%',
                                        contentPadding: EdgeInsets.symmetric(
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
                              // Observaciones opcionales de la partida; viajan
                              // en la columna `observa` del detalle.
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: TextField(
                                  controller: observaController,
                                  maxLength: 250,
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (value) {
                                    UtilsVenta.setObserva(clave, value);
                                    updateTotal();
                                  },
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                    labelText:
                                        'Observaciones de la partida (opcional)',
                                    labelStyle: TextStyle(fontSize: 11),
                                    counterText: '',
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),
                              if (selectedPrice == 3)
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
