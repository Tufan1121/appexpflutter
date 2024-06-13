import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/config.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/shared/widgets/widgets.dart'
    show LayoutScreens;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/widgets.dart';

class PreciosScreen extends StatelessWidget {
  const PreciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreens(
      icon: Icons.price_change,
      titleScreen: 'PRECIOS',
      child: Column(
        children: [
          const SearchPrices(),
          BlocBuilder<PreciosBloc, PreciosState>(
            builder: (context, state) {
              if (state is PreciosLoading) {
                return const Column(
                  children: [
                    SizedBox(
                      height: 150,
                    ),
                    CircularProgressIndicator(),
                  ],
                );
              } else if (state is PreciosLoaded) {
                double existencia = state.producto.bodega1 +
                    state.producto.bodega2 +
                    state.producto.bodega3 +
                    state.producto.bodega4;
                return Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Card(
                      child: Column(
                        children: [
                          Text(state.producto.producto,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text("Clave: ${state.producto.producto1}"),
                          Text("Existencia en Bodegas: $existencia"),
                          Text("Medidas: ${state.producto.medidas}"),
                          Text(
                              "Precio Lista: \$${state.producto.precio1.toDouble()}"),
                          Text(
                              "Precio Expo: \$${state.producto.precio2.toDouble()}"),
                          Text(
                              "Precio Mayoreo: \$${state.producto.precio3.toDouble()}"),
                          Row(
                            children: [
                              const Text("Composicion:"),
                              Column(
                                children: [
                                  Text(state.producto.compo1),
                                  Text(state.producto.compo2),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is PreciosError) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    Center(
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }
}

class SearchPrices extends StatelessWidget {
  const SearchPrices({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2.0, 5.0),
                  )
                ],
              ),
              child: TextField(
                style: const TextStyle(
                  color: Colores.secondaryColor,
                  fontSize: 16,
                ),
                obscureText: false,
                keyboardType: TextInputType.text,
                onChanged: (value) => context
                    .read<PreciosBloc>()
                    .add(GetPreciosEvent(clave: value)),
                onSubmitted: (value) => context
                    .read<PreciosBloc>()
                    .add(GetPreciosEvent(clave: value)),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.search,
                      color: Colores.secondaryColor,
                    ),
                  ),
                  hintText: 'Clave',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.only(left: 12.0, top: 5, bottom: 20),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ScannerDialog(
                child: ScannerPage(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(
                  8), // padding para cambiar el tamaño del botón Fondo del botón
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Colores.secondaryColor,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
