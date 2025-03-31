import 'package:flutter/material.dart';
import '../screens/welcome.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VitaSphere",
      home: const Welcome(),
    );
  }
}
