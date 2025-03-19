import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom.dart';

class Device extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const Device({super.key, this.connectedDevice});

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {

  late BluetoothDevice? _connectedDevice;

  // Estados de los componentes
  bool _ledState = false;
  bool _buzzerState = false;
  bool _vibrationState = false;
  bool _deviceState = false;

  // UUID del servicio y características BLE
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String LED_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String BUZZER_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  final String VIBRATION_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26aa";

  BluetoothCharacteristic? _ledCharacteristic;
  BluetoothCharacteristic? _buzzerCharacteristic;
  BluetoothCharacteristic? _vibrationCharacteristic;

  @override
  void initState() {
    super.initState();
    _connectedDevice = widget.connectedDevice;
    _connectToDevice();
  }

  @override
  void dispose() {
    // Asegúrate de apagar todos los componentes al salir
    _toggleLed(false);
    _toggleBuzzer(false);
    _toggleVibration(false);
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    if (widget.connectedDevice == null) {
      debugPrint("No hay dispositivo conectado");
      return;
    }

    try {
      // Descubrir servicios
      List<BluetoothService> services = await widget.connectedDevice!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == LED_CHARACTERISTIC_UUID) {
              _ledCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() ==
                BUZZER_CHARACTERISTIC_UUID) {
              _buzzerCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() ==
                VIBRATION_CHARACTERISTIC_UUID) {
              _vibrationCharacteristic = characteristic;
            }
          }
        }
      }

      setState(() {
        _deviceState = true;
      });

      // Leer estados iniciales
      _readInitialStates();
    } catch (e) {
      debugPrint("Error al conectar con el dispositivo: $e");
    }
  }

  Future<void> _readInitialStates() async {
    try {
      if (_ledCharacteristic != null && _ledCharacteristic!.properties.read) {
        final value = await _ledCharacteristic!.read();
        setState(() {
          _ledState = value[0] > 0;
        });
      }

      if (_buzzerCharacteristic != null &&
          _buzzerCharacteristic!.properties.read) {
        final value = await _buzzerCharacteristic!.read();
        setState(() {
          _buzzerState = value[0] > 0;
        });
      }

      if (_vibrationCharacteristic != null &&
          _vibrationCharacteristic!.properties.read) {
        final value = await _vibrationCharacteristic!.read();
        setState(() {
          _vibrationState = value[0] > 0;
        });
      }
    } catch (e) {
      debugPrint("Error al leer estados iniciales: $e");
    }
  }

  Future<void> _toggleLed(bool value) async {
    if (_ledCharacteristic != null && _ledCharacteristic!.properties.write) {
      try {
        await _ledCharacteristic!.write([value ? 1 : 0]);
        setState(() {
          _ledState = value;
        });
        debugPrint("LED ${value ? 'encendido' : 'apagado'}");
      } catch (e) {
        debugPrint("Error al cambiar el estado del LED: $e");
      }
    }
  }

  Future<void> _toggleBuzzer(bool value) async {
    if (_buzzerCharacteristic != null &&
        _buzzerCharacteristic!.properties.write) {
      try {
        await _buzzerCharacteristic!.write([value ? 1 : 0]);
        setState(() {
          _buzzerState = value;
        });
        debugPrint("Buzzer ${value ? 'encendido' : 'apagado'}");
      } catch (e) {
        debugPrint("Error al cambiar el estado del buzzer: $e");
      }
    }
  }

  Future<void> _toggleVibration(bool value) async {
    if (_vibrationCharacteristic != null &&
        _vibrationCharacteristic!.properties.write) {
      try {
        await _vibrationCharacteristic!.write([value ? 1 : 0]);
        setState(() {
          _vibrationState = value;
        });
        debugPrint("Vibración ${value ? 'encendida' : 'apagada'}");
      } catch (e) {
        debugPrint("Error al cambiar el estado de la vibración: $e");
      }
    }
  }

  Future<void> _toggleDevice(bool value) async {
    try {
      // Si se desactiva el dispositivo, apagamos todos los componentes
      if (!value) {
        await _toggleLed(false);
        await _toggleBuzzer(false);
        await _toggleVibration(false);
      }
      setState(() {
        _deviceState = value;
      });
    } catch (e) {
      debugPrint("Error al cambiar el estado del dispositivo: $e");
    }
  }

  Widget _buildControlTile(
      {required String title,
      required String subtitle,
      required IconData icon,
      required bool value,
      required Function(bool) onChanged,
      bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black54),
        ),
        title: Text(
          title,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.quicksand(
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: const Color(0xFF4D638C),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5DDDF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Control del dispositivo",
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
              Text(
                "Control del dispositivo",
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Configura tu dispositivo según tus necesidades!",
                style: GoogleFonts.quicksand(),
              ),
              const SizedBox(height: 32),
              // Control de dispositivo
              _buildControlTile(
                title: "Dispositivo",
                subtitle: "Encender/apagar",
                icon: Icons.devices,
                value: _deviceState,
                onChanged: _toggleDevice,
              ),
              // Control del LED
              _buildControlTile(
                title: "Led indicador",
                subtitle: "Encender/apagar",
                icon: Icons.lightbulb_outline,
                value: _ledState,
                onChanged: _toggleLed,
                enabled: _deviceState,
              ),
              // Control del Buzzer
              _buildControlTile(
                title: "Alarma",
                subtitle: "Encender/apagar",
                icon: Icons.notifications,
                value: _buzzerState,
                onChanged: _toggleBuzzer,
                enabled: _deviceState,
              ),
              // Control de la vibración
              _buildControlTile(
                title: "Vibración",
                subtitle: "Encender/apagar",
                icon: Icons.vibration,
                value: _vibrationState,
                onChanged: _toggleVibration,
                enabled: _deviceState,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Bottom(connectedDevice: _connectedDevice),
    );
  }
}
