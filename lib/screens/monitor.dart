import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/config.dart';
import '../db/database.dart';
import '../widgets/bottom.dart';
import '../widgets/profile_btn.dart';

class Monitor extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const Monitor({super.key, this.connectedDevice});

  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  BluetoothDevice? _connectedDevice;
  String nombre = "";
  Map<String, dynamic> data = {};

  Timer? _timer;

  @override
  void initState() {
    _connectedDevice = widget.connectedDevice;

    _cargarMet();
    _cargarNom();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _cargarMet();
      debugPrint("Cargando datos...");
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarNom() async {
    nombre = await MongoDatabase.obtenerNombre();
    setState(() {});
  }

  Future<void> _cargarMet() async {
    Map<String, dynamic>? event = await MongoDatabase.ultmetrica();

    if (event == null) return;

    int? caidas;
    if (event['caidas'] is Future<int>) {
      caidas = await event['caidas'];
    } else {
      caidas = event['caidas'];
    }

    setState(() {
      data = {
        'pulsaciones': event['pulsaciones'] ?? "No disponibles",
        'temperatura': _formatDecimal(event['temperatura']),
        'oxigenacion': _formatDecimal(event['oxigenacion']),
        'caidas': caidas ?? "No disponibles",
        'fecha': event['fecha'] ?? "No disponibles",
        'hora': event['hora'] ?? "No disponibles",
      };
    });
  }

  String _formatDecimal(dynamic value) {
    if (value == null) return "No disponibles";
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Monitoreo",
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: blue500,
        elevation: 0,
        actions: const [
          ProfileBtn(),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hola de nuevo, $nombre!",
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      color: outerSpace,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Estas son tus mediciones más recientes.",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: outerSpace,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _metrics()
            ),
          ],
        ),
      ),
      bottomNavigationBar: Bottom(connectedDevice: _connectedDevice),
    );
  }

  Widget _metrics() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        _metricCard("Pulso", data['pulsaciones'], 1),
        _metricCard("Oxigenación", data['oxigenacion'], 2),
        _metricCard("Temperatura", data['temperatura'], 3),
        _metricCard("Caídas", data['caidas'], 4),
        _metricCard("Fecha", data['fecha'], 5),
        _metricCard("Hora", data['hora'], 6),
      ],
    );
  }

  Widget _metricCard(String titulo, dynamic valor, int n) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(valor?.toString() ?? "No disponible",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            images(n),
          ],
        ),
      ),
    );
  }

  Widget images(int num) {
    switch (num) {
      case 1:
        return Icon(
          Icons.monitor_heart,
          size: 30,
          color: Colors.red.shade900,
        );
      case 2:
        return Icon(
          Icons.cloud,
          size: 30,
          color: Colors.blue.shade100,
        );
      case 3:
        return Icon(
          Icons.ac_unit_rounded,
          size: 30,
          color: Colors.blue.shade900,
        );
      case 4:
        return Icon(
          Icons.personal_injury,
          size: 30,
          color: Colors.brown.shade400,
        );
      case 5:
        return Icon(
          Icons.calendar_month,
          size: 30,
          color: Colors.green.shade900,
        );
      case 6:
        return Icon(
          Icons.timer,
          size: 30,
          color: Colors.orange.shade300,
        );
    }
    return Icon(Icons.star);
  }
}
