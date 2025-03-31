import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database.dart';
import '../widgets/profile_btn.dart';
import '../widgets/bottom.dart';
import 'device.dart';
import '../config/config.dart';

class Pair extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const Pair({super.key, this.connectedDevice});

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

    _connectedDevice = widget.connectedDevice;

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
          withNames: ["VitaSphereV1"], timeout: Duration(seconds: 15));
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

      MongoDatabase.ligarDispositivo(device.platformName);

      // Detener el escaneo
      await _stopScan();

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
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Device(connectedDevice: _connectedDevice)),
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

  Widget _buildDeviceList() {
    List<BluetoothDevice> allDevices = [];

    // Añadir dispositivo conectado si existe
    if (_connectedDevice != null) {
      allDevices.add(_connectedDevice!);
    }

    // Añadir resultados del escaneo excluyendo el dispositivo conectado
    for (var result in _scanResults) {
      if (result.device.remoteId != _connectedDevice?.remoteId) {
        allDevices.add(result.device);
      }
    }

    return allDevices.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth,
                  size: 48,
                  color: blue200,
                ),
                const SizedBox(height: 16),
                if (_adapterState == BluetoothAdapterState.on)
                  Text(
                    'Buscando dispositivos...',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: blue500,
                    ),
                  )
                else
                  Text(
                    'Bluetooth desactivado',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: blue500,
                    ),
                  ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: allDevices.length,
            itemBuilder: (context, index) {
              final device = allDevices[index];
              final isConnected = _connectedDevice?.remoteId == device.remoteId;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isConnected? mineralGreen: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bluetooth,
                      color: isConnected? Colors.white: Colors.black,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    device.platformName.isNotEmpty
                        ? device.platformName
                        : "Dispositivo sin nombre",
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? outerSpace : blue500,
                    ),
                  ),
                  subtitle: Text(
                    isConnected ? "Conectado" : "Disponible",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: isConnected ? outerSpace : blue500,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: isConnected
                        ? _disconnectDevice
                        : () => _connectToDevice(device),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isConnected ? Colors.red.shade100 : mineralGreen,
                      foregroundColor:
                          isConnected ? Colors.red.shade700 : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isConnected ? "Desconectar" : "Conectar",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Conectar Dispositivo",
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
            // Header Section
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Conecta tu VitaSphere e inicia tu tranquilidad!",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: outerSpace,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Bluetooth Toggle Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: blue500.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _adapterState == BluetoothAdapterState.on? mineralGreen: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bluetooth,
                      size: 24,
                      color: _adapterState == BluetoothAdapterState.on? Colors.white: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bluetooth',
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: outerSpace,
                          ),
                        ),
                        Text(
                          _adapterState == BluetoothAdapterState.on
                              ? 'Activado'
                              : 'Desactivado',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: blue200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _adapterState == BluetoothAdapterState.on,
                    onChanged: (value) async => await _toggleBluetooth(value),
                    activeColor: mineralGreen,
                    activeTrackColor: mineralGreen.withOpacity(0.5),
                    inactiveThumbColor: blue200,
                    inactiveTrackColor: blue100,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.transparent; // Color del borde cuando está activado
                        }
                        return Colors.transparent; // Color del borde cuando está desactivado
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Device List Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dispositivos',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: outerSpace,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de dispositivos detectados
            Expanded(
              child: AnimatedOpacity(
                opacity: _adapterState == BluetoothAdapterState.on ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDeviceList(),
                ),
              ),
            ),

            // Mensaje de estado del Bluetooth
            if (_adapterState != BluetoothAdapterState.on)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Activa el Bluetooth para buscar dispositivos cercanos',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: outerSpace,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _adapterState == BluetoothAdapterState.on
          ? FloatingActionButton(
              onPressed: _isScanning
                  ? _stopScan
                  : _adapterState == BluetoothAdapterState.on
                      ? _startScan
                      : null,
              backgroundColor: _adapterState == BluetoothAdapterState.on
                  ? blue500
                  : Colors.transparent,
              child: Icon(
                _isScanning ? Icons.stop : Icons.refresh,
                color: Colors.white,
              ),
            )
          : null,
      bottomNavigationBar: Bottom(connectedDevice: _connectedDevice),
    );
  }
}
