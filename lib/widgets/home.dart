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
          Text("Tecnología que salva vidas, al instante"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Registrar(),
                        ));
                  },
                  child: Text("Regsitrarse")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Iniciar(),
                        ));
                  },
                  child: Text("Iniciar Seccion")),
              ElevatedButton(
                  onPressed: () async {
                    await MongoDatabase.cerrarSesion();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Iniciar(),
                        ));
                  },
                  child: Text("Cerrar sesion"))
            ],
          )
        ],
      ),
    ));
  }
}
