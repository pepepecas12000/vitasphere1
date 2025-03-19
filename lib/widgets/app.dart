import 'package:flutter/material.dart';
import 'package:vitasphere1/widgets/iniciar.dart'; // LoginPage
import 'package:vitasphere1/widgets/inicio.dart';
import 'home.dart'; // Pantalla principal después de login

class App extends StatelessWidget {
  final String? userEmail;
  const App({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VitaSphere",
      home: userEmail != null ? const Inicio() : const Iniciar(),
    );
  }
}
