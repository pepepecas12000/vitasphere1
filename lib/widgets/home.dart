import 'package:flutter/material.dart';
import 'package:vitasphere1/db/database.dart';
import 'package:vitasphere1/widgets/registrar.dart';

import 'iniciar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("VitaSphere"),
          Text("Alerta inteligente, cuidado inmediato"),
        ],
      ),
    ));
  }
}
