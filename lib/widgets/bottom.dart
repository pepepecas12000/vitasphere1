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

  void _notActual(BuildContext context, String route, Widget page) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: route),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF001D47),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.link, color: Color(0xFFB0B8CF)),
            onPressed: () => _notActual(
              context,
              '/pair',
              _connectedDevice == null
                  ? Pair()
                  : Pair(connectedDevice: _connectedDevice),
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Color(0xFFB0B8CF)),
            onPressed: () => _notActual(
              context,
              '/monitor',
              _connectedDevice == null
                  ? Monitor()
                  : Monitor(connectedDevice: _connectedDevice),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFFB0B8CF)),
            onPressed: () {
              if (_connectedDevice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "No hay ningún dispositivo conectado",
                      style: const TextStyle(color: Color(0xFFB0B8CF), fontSize: 18),
                    ),
                    backgroundColor: Color(0xFF4D638C),
                  ),
                );
                return;
              }
              _notActual(
                context,
                '/device',
                Device(connectedDevice: _connectedDevice),
              );
            },
          ),
        ],
      ),
    );
  }
}
