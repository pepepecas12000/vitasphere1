import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../db/database.dart';
import '../widgets/bottom.dart';

class Monitor extends StatefulWidget {
  //final BluetoothDevice? connectedDevice;



   const Monitor({super.key});


  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  String nombre="x";

  Map<String,dynamic> datos={};
  @override
  void initState() {
    super.initState();

    // Cargar métricas cuando se inicie el widget
    _cargarMetricas();
    actuNombre();
  }

    void actuNombre()async{
    nombre= await MongoDatabase.obtenerNombre();
    setState(() {

    });
    }


  void _cargarMetricas() async {

    Stream<Map<String, dynamic>>? metricas = await MongoDatabase.ultmetrica();
    metricas?.listen((event) {
      if (datos['hora'] == event['hora'] && datos['fecha'] == event['fecha']) {
        return; // No actualiza si los datos son los mismos
      }

      setState(() {
        datos = {
          'pulsaciones': event['pulsaciones'] ?? "No disponibles",
          'temperatura': event['temperatura'] ?? "No disponibles",
          'oxigenacion': event['oxigenacion'] ?? "No disponibles",
          'fecha': event['fecha'] ?? "No disponibles",
          'hora': event['hora'] ?? "No disponibles",
        };

      });
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
           Text("Hola de nuevo, $nombre"),
          const SizedBox(height: 8),
          const Text("Aquí tienes las mediciones más recientes del usuario"),
          const SizedBox(height: 32),
          Expanded(
            child: _listmetrics() ?? const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),

    );
  }

  Widget _listmetrics() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _metricCard("Pulso", datos['pulsaciones'],1),
        _metricCard("Oxigenación", datos['oxigenacion'],2),
        _metricCard("Temperatura", datos['temperatura'],3),
        _metricCard("Fecha", datos['fecha'],4),
        _metricCard("Hora", datos['hora'],5),
      ],
    );
  }

// Función para crear una Card con cada métrica
  Widget _metricCard(String titulo, dynamic valor, int n) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaciado entre elementos
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(valor?.toString() ?? "No disponible", style: const TextStyle(fontSize: 14)),
              ],
            ),
            imagens(n),
          ],
        ),
      ),
    );
  }

  Widget imagens(int num){
    switch(num){
      case 1:
        // icono de pulsaciones
        return Icon(Icons.monitor_heart,  size: 30);
      case 2:
      // icono de pulsaciones
        return Icon(Icons.add_chart_sharp, size: 30);
      case 3:
      // icono de pulsaciones
        return Icon(Icons.severe_cold, size: 30);
      case 4:
      // icono de pulsaciones
        return Icon(Icons.calendar_month, size: 30);
      case 5:
      // icono de pulsaciones
        return Icon(Icons.timer, size: 30);

    }
    return Icon(Icons.extension_off_outlined);
  }


}
