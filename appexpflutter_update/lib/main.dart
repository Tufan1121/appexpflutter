import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:appexpflutter_update/my_app.dart';
import 'package:appexpflutter_update/config/my_http_overrides.dart';
import 'package:appexpflutter_update/features/auth/config/config_token.dart';
import 'package:appexpflutter_update/features/galeria/data/data_sources/galerIa_data_source_impl.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_galeria/detalle_galeria_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/detalle_producto/detalle_producto_bloc.dart';
import 'package:appexpflutter_update/features/galeria/presentation/blocs/galeria/galeria_bloc.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source.dart';
import 'package:appexpflutter_update/features/historial/data/data_sources/historial_data_source_impl.dart';
import 'package:appexpflutter_update/features/historial/data/repositories/historial_repository_impl.dart';
import 'package:appexpflutter_update/features/historial/domain/respositories/historial_repository.dart';
import 'package:appexpflutter_update/features/historial/domain/usecases/historial_usecase.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/historial/historial_bloc.dart';
import 'package:appexpflutter_update/features/historial/presentation/blocs/sesion/sesion_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/data/data_sources/inventario_expo_data_source_impl.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/busqueda_global/busqueda_global_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_bodega/inventario_bodega_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/blocs/inventario_expo/inventario_expo_bloc.dart';
import 'package:appexpflutter_update/features/inventarios/presentation/cubits/medias/medidas_cubit.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/consulta/consulta_datasource.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/consulta/consulta_datasource_imp.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/inventario_expo/inventario_expo_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/inventario_expo/inventario_expo_data_source_impl.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/pedido/pedido_data_source.dart';
import 'package:appexpflutter_update/features/punto_venta/data/data_sources/pedido/pedido_data_source.impl.dart';
import 'package:appexpflutter_update/features/punto_venta/data/repositories/inventario_expo_repository_impl.dart';
import 'package:appexpflutter_update/features/punto_venta/data/repositories/pedido_repository_impl.dart';
import 'package:appexpflutter_update/features/punto_venta/data/repositories/tickets_repository_impl.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/inventario_expo_repository.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/pedido_repository.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/repositories/tickets_repository.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/cliente_usecase.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/inventario_expo_usecase.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/pedido_usecase.dart';
import 'package:appexpflutter_update/features/punto_venta/domain/usecases/tickets_usecase.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/consulta/consulta_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/inventario_tienda/inventario_tienda_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/punto_venta/presentation/blocs/producto/productos_tienda_bloc.dart';
import 'package:appexpflutter_update/features/reportes/data/data_sources/sales_datasource.dart';
import 'package:appexpflutter_update/features/reportes/data/data_sources/sales_datasource_imp.dart';
import 'package:appexpflutter_update/features/reportes/data/repositories/sales_repository_imp.dart';
import 'package:appexpflutter_update/features/reportes/domain/repositories/sales_repository.dart';
import 'package:appexpflutter_update/features/reportes/domain/usecases/sales_usecase.dart';
import 'package:appexpflutter_update/features/reportes/presentation/bloc/reportes_bloc.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/cliente/cliente_data_source_impl.dart';
import 'package:appexpflutter_update/features/ventas/data/data_sources/pedido/pedido_data_source.impl.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cliente/cliente_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/cotiza_pedido/cotiza_pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/inventario/inventario_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/pedido/pedido_bloc.dart';
import 'package:appexpflutter_update/features/ventas/presentation/blocs/session_pedido/sesion_pedido_bloc.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source_impl.dart';
import 'package:appexpflutter_update/features/precios/data/data_sources/producto_data_source_impl.dart';
import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/ventas/presentation/blocs/producto/productos_bloc.dart';

//* LIBRERIAS
import 'package:api_client/dio_client.dart';
import 'package:api_client/constants/environment.dart';

import 'package:login/data/data_sources/auth_data_source.dart';
import 'package:login/data/repositories/auth_repository_impl.dart';
import 'package:login/domain/repositories/auth_repository.dart';
import 'package:login/domain/usecases/auth_usecase.dart';

import 'package:inventarios/data/data_sources/inventario_expo_data_source.dart';
import 'package:inventarios/domain/repositories/inventario_expo_repository.dart';
import 'package:inventarios/data/repositories/inventario_expo_repository_impl.dart';
import 'package:inventarios/domain/usecases/inventario_expo_usecase.dart';

import 'package:sesion_ventas/data/data_sources/cliente/cliente_data_source.dart';
import 'package:sesion_ventas/data/data_sources/pedido/pedido_data_source.dart';
import 'package:sesion_ventas/data/repositories/cliente_repository_impl.dart';
import 'package:sesion_ventas/data/repositories/pedido_repository_impl.dart';
import 'package:sesion_ventas/domain/repositories/cliente_repository.dart';
import 'package:sesion_ventas/domain/repositories/pedido_repository.dart';
import 'package:sesion_ventas/domain/usecases/cliente_usecase.dart';
import 'package:sesion_ventas/domain/usecases/pedido_usecase.dart';

import 'package:galeria/data/data_sources/galeria_data_source.dart';
import 'package:galeria/data/repositories/galeria_repository_impl.dart';
import 'package:galeria/domain/repositories/galeria_repository.dart';
import 'package:galeria/domain/usecase/galeria_usecases.dart';

import 'package:precios/data/data_sources/producto_data_source.dart';
import 'package:precios/data/repositories/producto_repository_impl.dart';
import 'package:precios/domain/repositories/producto_repository.dart';
import 'package:precios/domain/usecases/producto_usecase.dart';

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
