import 'package:flutter/material.dart';
class Registrar extends StatefulWidget {
  const Registrar({super.key});

  @override
  State<Registrar> createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Registrarse"),
    );
  }
}
