import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/mixins/modal.dart';

import 'package:appexpflutter_update/features/home/presentation/screens/widgets/custom_list_tile.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/popover.dart';
import 'package:appexpflutter_update/features/shared/widgets/layout_screens.dart';
import 'package:appexpflutter_update/features/ventas/presentation/bloc/cliente/cliente_bloc.dart';
import '../../../../config/config.dart';
import 'widgets/widgets.dart' show SearchClientes;

class ClienteExistenteScreen extends StatelessWidget with Modal {
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
          const SizedBox(height: 20),
          const SearchClientes(),
          BlocConsumer<ClienteBloc, ClienteState>(
            listener: (context, state) {
              if (state is ClienteLoaded && state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ClienteError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
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
                            onLongPress: () => showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) => Popover(
                                child: Container(
                                  height: 100,
                                  color: Colores.scaffoldBackgroundColor,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: ListView(
                                      children: [
                                        CustomListTile(
                                          text: 'EDITAR CLIENTE',
                                          icon: FontAwesomeIcons.userPlus,
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            Navigator.pop(context);
                                            modalEditarCliente(size, context,
                                                state.clientes[index]);
                                          },
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              PedidoRoute($extra: state.clientes[index])
                                  .push(context);
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
                              '${state.clientes[index].nombre} ${state.clientes[index].apellido}',
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
