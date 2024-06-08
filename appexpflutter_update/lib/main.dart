import 'package:appexpflutter_update/config/config.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/auth/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tufan',
      home: LoginScreen(),
    );
  }
}
