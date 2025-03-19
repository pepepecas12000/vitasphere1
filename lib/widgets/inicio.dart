import 'package:flutter/material.dart';
import 'package:vitasphere1/db/database.dart';
import 'package:vitasphere1/widgets/iniciar.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VitaSphere'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              '¡Bienvenido a VitaSphere!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Acción para ir a la sección de "Signos Vitales"
              },
              child: const Text('Ver Signos Vitales'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Acción para ir a la sección de "Historial Médico"
              },
              child: const Text('Historial Médico'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                MongoDatabase.cerrarSesion();
                Navigator.push(context, MaterialPageRoute(builder: (context) => Iniciar(),));
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
