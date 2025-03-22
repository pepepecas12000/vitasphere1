import 'package:flutter/material.dart';
import '../db/database.dart';
import '../screens/iniciar.dart';

class ProfileBtn extends StatelessWidget {
  const ProfileBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.account_circle),
        color: Color(0xFFB0B8CF),
        onSelected: (String value) {
          if (value == "l") MongoDatabase.cerrarSesion();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Iniciar(),
              ));
        },
        itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                  value: "l",
                  child: Center(
                    child: Text("Cerrar sesión"),
                  ))
            ]);
  }
}
