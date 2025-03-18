import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'device.dart';
import '../widgets/bottom_bar.dart';

class Pair extends StatefulWidget {
  const Pair({super.key});

  @override
  _PairState createState() => _PairState();
}

class _PairState extends State<Pair> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectedDeviceSubscription;

  @override
  void initState() {
    super.initState();

    // Escuchar el estado del Bluetooth
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });

      if (state == BluetoothAdapterState.on) {
        _startScan();
      } else {
        _stopScan();
        _scanResults.clear();
      }
    });

    // Escuchar los dispositivos detectados
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _connectedDeviceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _toggleBluetooth(bool enable) async {
    try {
      if (enable) {
        await FlutterBluePlus.turnOn();
      } else {
        await FlutterBluePlus.turnOff();
      }
    } catch (e) {
      debugPrint("Error al cambiar el estado del Bluetooth: $e");
    }
  }

  Future<void> _startScan() async {
    if (!_isScanning) {
      setState(() {
        _isScanning = true;
      });
      await FlutterBluePlus.startScan(
          withNames: ["VitaSphereV1"], timeout: const Duration(seconds: 10));
    }
  }

  Future<void> _stopScan() async {
    setState(() {
      _isScanning = false;
    });
    await FlutterBluePlus.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      debugPrint("Dispositivo emparejado");
      setState(() {
        _connectedDevice = device;
      });

      // Escuchar la desconexión solo después de conectarse
      _connectedDeviceSubscription =
          device.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint(
              "${device.disconnectReason?.code} ${device.disconnectReason?.description}");
          setState(() {
            _connectedDevice = null;
          });
        }
      });

      // Cancelar la suscripción cuando el dispositivo se desconecte
      device.cancelWhenDisconnected(_connectedDeviceSubscription!,
          delayed: true, next: true);

      // Navegar a la siguiente pantalla
      // Navegar a la siguiente pantalla
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Device(device: _connectedDevice)),
        );
      }
    } catch (e) {
      debugPrint("Error al emparejar: $e");
    }
  }

  Future<void> _disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        debugPrint("Dispositivo desemparejado");
      } catch (e) {
        debugPrint("Error al desemparejar: $e");
      } finally {
        setState(() {
          _connectedDevice = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5DDDF),
      appBar: AppBar(
        title: Text(
          "Conectar",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4D638C),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Conectar dispositivo"),
              const SizedBox(height: 8),
              Text("Conecta tu dispositivo e inicia tu tranquilidad"),
              const SizedBox(height: 32),

              // Tarjeta Bluetooth
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bluetooth'),
                          const Text('Encender/apagar'),
                        ],
                      ),
                    ),
                    Switch(
                      value: _adapterState == BluetoothAdapterState.on,
                      onChanged: (value) async => await _toggleBluetooth(value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Lista de dispositivos detectados
              Text('Lista de dispositivos'),
              const SizedBox(height: 16),

              Expanded(
                child: AnimatedOpacity(
                  opacity:
                      _adapterState == BluetoothAdapterState.on ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      final device = result.device;

                      return ListTile(
                        leading: const Icon(Icons.devices),
                        title: Text(device.platformName.isNotEmpty
                            ? device.platformName
                            : "Dispositivo sin nombre"),
                        trailing: _connectedDevice?.remoteId == device.remoteId
                            ? ElevatedButton(
                                onPressed: _disconnectDevice,
                                child: const Text("Desconectar"),
                              )
                            : ElevatedButton(
                                onPressed: () => _connectToDevice(device),
                                child: const Text("Conectar"),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
