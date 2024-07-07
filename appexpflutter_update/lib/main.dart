import 'dart:io';

import 'package:appexpflutter_update/config/my_http_overrides.dart';
import 'package:appexpflutter_update/features/auth/config/config_token.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source_impl.dart';
import 'package:appexpflutter_update/features/historial/data/repositories/historial_repository_impl.dart';
import 'package:appexpflutter_update/features/historial/domain/respositories/historial_repository.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:appexpflutter_update/features/historial/presentation/bloc/historial_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/data/data_sources/inventario_expo_data_source.dart';
import 'package:appexpflutter_update/features/inventarios/data/data_sources/inventario_expo_data_source_impl.dart';
import 'package:appexpflutter_update/features/inventarios/data/repositories/inventario_expo_repository_impl.dart';
import 'package:appexpflutter_update/features/inventarios/domain/repositories/inventario_expo_repository.dart';
import 'package:appexpflutter_update/features/inventarios/domain/usecases/inventario_expo_usecase.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/busqueda_global/busqueda_global_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_bodega/inventario_bodega_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_expo/inventario_expo_bloc.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/cliente/cliente_data_source.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/cliente/cliente_data_source_impl.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.impl.dart';
import 'package:appexpflutter_update/features/ventas/data/repositories/cliente_repository_impl.dart';
import 'package:appexpflutter_update/features/ventas/data/repositories/pedido_repository_impl.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/cliente_repository.dart';
import 'package:appexpflutter_update/features/ventas/domain/repositories/pedido_repository.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/cliente_usecase.dart';
import 'package:appexpflutter_update/features/ventas/domain/usecases/pedido_usecase.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cotiza_pedido/cotiza_pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/inventario/inventario_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/session_pedido/sesion_pedido_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:api_client/dio_client.dart';
import 'package:appexpflutter_update/my_app.dart';
import 'package:api_client/constants/environment.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source_impl.dart';
import 'package:appexpflutter_update/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:appexpflutter_update/features/auth/domain/repositories/auth_repository.dart';
import 'package:appexpflutter_update/features/auth/domain/usecases/auth_usecase.dart';
import 'package:appexpflutter_update/features/precios/data/data_sources/producto_data_source.dart';
import 'package:appexpflutter_update/features/precios/data/data_sources/producto_data_source_impl.dart';
import 'package:appexpflutter_update/features/precios/data/repositories/producto_repository_impl.dart';
import 'package:appexpflutter_update/features/precios/domain/repositories/producto_repository.dart';
import 'package:appexpflutter_update/features/precios/domain/usecases/producto_usecase.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/ventas/presentation/blocs/producto/productos_bloc.dart';
part './injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  await ConfigToken().checkAndDeleteTokenIfNeeded();
  await init();
  // HttpOverrides para antes de iniciar la aplicación
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}
