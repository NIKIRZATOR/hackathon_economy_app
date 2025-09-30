import 'package:flutter/material.dart';
import 'core/layout/app_view_size.dart';
import 'features/auth/screens/auth_screen.dart';

const bool kForcePhoneFrame = true; // true = рамка 414x660
const double kPhoneWidth = 414;
const double kPhoneHeight = 660;

class CapitalCityApp extends StatelessWidget {
  const CapitalCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Город Капитала — MVP Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),

      builder: (context, child) {
        final content = child ?? const AuthScreen();
        return AppViewSize.decide(
          context: context,
          usePhoneFrame: kForcePhoneFrame,
          phoneW: kPhoneWidth,
          phoneH: kPhoneHeight,
          child: content,
        );
      },

      home: const AuthScreen(),
    );
  }
}
