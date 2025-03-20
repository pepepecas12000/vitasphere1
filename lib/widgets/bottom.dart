import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../screens/device.dart';
import '../screens/monitor.dart';
import '../screens/pair.dart';

class Bottom extends StatefulWidget {
  final BluetoothDevice? connectedDevice;
  const Bottom({super.key, this.connectedDevice});

  @override
  _BottomState createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  late BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _connectedDevice = widget.connectedDevice;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF001D47),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.link, color: Color(0xFFD5DDDF)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Pair(connectedDevice: _connectedDevice)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Color(0xFFD5DDDF),),
            onPressed: () {
              if (_connectedDevice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "No hay ningún dispositivo conectado",
                      style: const TextStyle(color: Color(0xFFB0B8CF)),
                    ),
                    backgroundColor: Color(0xFF4D638C),
                  ),
                );
                return;
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Monitor(connectedDevice: _connectedDevice)),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFFD5DDDF)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Device(connectedDevice: _connectedDevice)),
            ),
          )
        ],
      ),
    );
  }
}
