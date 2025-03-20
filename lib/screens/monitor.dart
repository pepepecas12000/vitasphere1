import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../db/database.dart';
import '../widgets/bottom.dart';

class Monitor extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const Monitor({super.key, this.connectedDevice});

  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  late BluetoothDevice? _connectedDevice;
  Widget? _metricasWidget;

  @override
  void initState() {
    super.initState();
    _connectedDevice = widget.connectedDevice;

    // Cargar métricas cuando se inicie el widget
    _cargarMetricas();
  }

  void _cargarMetricas() async {
    var widgetMetricas = await _listmetrics();
    setState(() {
      _metricasWidget = widgetMetricas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Monitoreo"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hola de nuevo, x"),
          const SizedBox(height: 8),
          const Text("Aquí tienes las mediciones más recientes del usuario"),
          const SizedBox(height: 32),
          Expanded(
            child: _metricasWidget ?? const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      bottomNavigationBar: Bottom(connectedDevice: _connectedDevice),
    );
  }

  Future<Widget> _listmetrics() async {
    var metricas = await MongoDatabase.ultmetrica();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        metricas != null ? metricas.toString() : "No hay métricas disponibles.",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
