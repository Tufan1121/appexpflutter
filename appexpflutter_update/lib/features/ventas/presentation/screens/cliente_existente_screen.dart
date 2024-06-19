import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/cliente_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../config/config.dart';
import 'widgets/widgets.dart' show SearchClientes;

class ClienteExistenteScreen extends StatelessWidget {
  const ClienteExistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LayoutScreens(
      onPressed: () => Navigator.pop(context),
      titleScreen: 'CLIENTE EXISTENTE',
      faIcon: FontAwesomeIcons.userCheck,
      child: Column(
        children: [
          const SearchClientes(),
          BlocBuilder<ClienteBloc, ClienteState>(
            builder: (context, state) {
              if (state is ClienteLoading) {
                return const Column(
                  children: [
                    SizedBox(height: 150),
                    CircularProgressIndicator(
                      color: Colores.secondaryColor,
                    ),
                  ],
                );
              }
              if (state is ClienteLoaded) {
                return SizedBox(
                  height: size.height * 0.80,
                  child: ListView.builder(
                    itemCount: state.clientes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            onTap: () {
                              print(state.clientes[index].idCliente);
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                  color: Colores.scaffoldBackgroundColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,

                                      blurRadius: 1,
                                      offset: Offset(
                                          0, 4), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.userLarge,
                                  color: Colores.secondaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            title: AutoSizeText(
                              state.clientes[index].nombre,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: AutoSizeText(
                              'Telefono: ${state.clientes[index].telefono}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              if (state is ClienteError) {
                return Column(
                  children: [
                    const SizedBox(height: 150),
                    Center(
                      child: SizedBox(
                        height: 60,
                        width: 300,
                        child: Card(
                          child: AutoSizeText(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          )
        ],
      ),
    );
  }
}
