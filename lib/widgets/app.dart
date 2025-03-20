import 'package:flutter/material.dart';
import '../screens/welcome.dart';

class App extends StatelessWidget {
  final String? userEmail;
  const App({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VitaSphere",
      home: userEmail != null ? Welcome(userEmail: userEmail) : const Welcome(),
    );
  }
}
