import 'package:appexpflutter_update/features/shared/widgets/custom_appbar.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/inventario/inventario_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/producto/productos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:appexpflutter_update/features/ventas/presentation/screens/mixins/modal.dart';

import 'package:appexpflutter_update/features/home/presentation/screens/widgets/custom_list_tile.dart';
import 'package:appexpflutter_update/features/home/presentation/screens/widgets/popover.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import '../../../../config/config.dart';
import 'widgets/widgets.dart' show SearchClientes;

class ClienteExistenteScreen extends StatelessWidget with Modal {
  const ClienteExistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      // Permite la navegación hacia atrás nativa
      onPopInvoked: (didPop) async {
        context.read<ClienteBloc>().add(ClearClienteStateEvent());
        context.read<ProductosBloc>().add(ClearProductoStateEvent());
        context.read<InventarioBloc>().add(ClearInventarioProductoEvent());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.7],
                ),
              ),
            ),
            Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(40.0),
                  child: CustomAppBar(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    onPressed: () {
                      context.read<ClienteBloc>().add(ClearClienteStateEvent());
                      context
                          .read<ProductosBloc>()
                          .add(ClearProductoStateEvent());
                      context
                          .read<InventarioBloc>()
                          .add(ClearInventarioProductoEvent());
                      Navigator.pop(context);
                    },
                    title: 'CLIENTE EXISTENTE',
                  ),
                ),
                const SizedBox(height: 5),
                const SearchClientes(),
                Expanded(
                  child: BlocConsumer<ClienteBloc, ClienteState>(
                    listener: (context, state) {
                      if (state is ClienteLoaded && state.message != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message!),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is ClienteLoading) {
                        return Column(
                          children: [
                            const SizedBox(height: 150),
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Card(
                                  elevation: 4,
                                  child: ListTile(
                                    onLongPress: () => showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) =>
                                          Popover(
                                        child: Container(
                                          height: 100,
                                          color:
                                              Theme.of(context).colorScheme.surface,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: ListView(
                                              children: [
                                                CustomListTile(
                                                  text: 'EDITAR CLIENTE',
                                                  icon:
                                                      FontAwesomeIcons.userPlus,
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    Navigator.pop(context);
                                                    modalEditarCliente(
                                                        size,
                                                        context,
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
                                      PedidoRoute(
                                        idCliente:
                                            state.clientes[index].idCliente,
                                        nombreCliente:
                                            state.clientes[index].nombre,
                                        telefonoCliente:
                                            state.clientes[index].telefono,
                                      ).push(context);
                                    },
                                    leading: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).colorScheme.surface,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 1,
                                              offset: Offset(0,
                                                  4), // changes position of shadow
                                            ),
                                          ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))),
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.userLarge,
                                          color: Theme.of(context).colorScheme.primary,
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
