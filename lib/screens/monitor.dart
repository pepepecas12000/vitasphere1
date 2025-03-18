import 'package:flutter/material.dart';
import '../widgets/bottom_bar.dart';

class Monitor extends StatefulWidget {
  const Monitor({Key? key}) : super(key: key);

  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monitoreo"),
      ),
      body: Container(),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
