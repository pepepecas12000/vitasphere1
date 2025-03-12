import 'package:flutter/material.dart';
import 'package:vitasphere1/widgets/iniciar.dart';

import 'home.dart';
 class App extends StatelessWidget {
   final String? userEmail;
   const App({super.key, this.userEmail});

   @override
   Widget build(BuildContext context) {
     return  MaterialApp(
       debugShowCheckedModeBanner: false,
       title: "VitaSphere",
       //theme: ThemeData(fontFamily: "outfit", primarySwatch: Colors.lightBlue),
       initialRoute: "home",
       home: userEmail != null ? Home() : Iniciar(),
     );
   }
 }
