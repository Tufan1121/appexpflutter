import 'package:api_client/dio_client.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source.dart';
import 'package:appexpflutter_update/features/auth/data/data_sources/auth_data_source_impl.dart';
import 'package:appexpflutter_update/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:appexpflutter_update/features/auth/domain/repositories/auth_repository.dart';
import 'package:appexpflutter_update/features/auth/domain/usecases/auth_usecase.dart';
import 'package:flutter/material.dart';
import 'package:api_client/constants/environment.dart';
import 'package:appexpflutter_update/my_app.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
part './injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  await init();
  runApp(const MyApp());
}
