import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../widgets/bottom.dart';

class Monitor extends StatefulWidget {

  final BluetoothDevice? connectedDevice;

  const Monitor({super.key, this.connectedDevice});

  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {

  late BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _connectedDevice = widget.connectedDevice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Monitoreo"),
      ),
      body: Container(),
      bottomNavigationBar: Bottom(connectedDevice: _connectedDevice),
    );
  }
}
