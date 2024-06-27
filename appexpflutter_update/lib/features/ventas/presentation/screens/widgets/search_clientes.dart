import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/widgets.dart' show CustomSearch;

class SearchClientes extends StatelessWidget {
  const SearchClientes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: CustomSearch(
              hintText: 'Cliente',
              onChanged: (value) {
                context.read<ClienteBloc>().add(GetClientesEvent(name: value));
              },
              onSubmitted: (value) => context
                  .read<ClienteBloc>()
                  .add(GetClientesEvent(name: value)),
            ),
          ),
        ],
      ),
    );
  }
}

// class CustomSearch extends StatelessWidget {
//   const CustomSearch({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       style: const TextStyle(
//         color: Colores.secondaryColor,
//         fontSize: 16,
//       ),
//       obscureText: false,
//       keyboardType: TextInputType.text,
      // onChanged: (value) {
      //   context
      //       .read<ClienteBloc>()
      //       .add(GetClientesEvent(name: value));
      // },
      // onSubmitted: (value) => context
      //     .read<ClienteBloc>()
      //     .add(GetClientesEvent(name: value)),
//       decoration: InputDecoration(
//         prefixIcon: const Padding(
//           padding: EdgeInsets.all(10.0),
//           child: Icon(
//             Icons.search,
//             color: Colores.secondaryColor,
//           ),
//         ),
//         hintText: 'Cliente',
//         hintStyle: const TextStyle(color: Colors.grey),
//         fillColor: Colors.white,
//         filled: true,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding:
//             const EdgeInsets.only(left: 12.0, top: 5, bottom: 20),
//       ),
//     );
//   }
// }
