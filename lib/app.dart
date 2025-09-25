import 'package:flutter/material.dart';
import 'features/auth/screens/auth_screen.dart';

class CapitalCityApp extends StatelessWidget {
  const CapitalCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Город Капитала — MVP Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AuthScreen(),
    );
  }
}