import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitasphere1/widgets/profile_btn.dart';
import '../widgets/bottom.dart';
import '../db/database.dart';

class Device extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const Device({super.key, this.connectedDevice});

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  late String? _userId;
  late BluetoothDevice? _connectedDevice;

  // Estados de los componentes
  bool _ledState = false;
  bool _buzzerState = false;
  bool _vibrationState = false;
  bool _deviceState = false;

  bool _alarmState = false;

  // UUID del servicio y características BLE
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  final String USER_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26ab";
  final String LED_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String BUZZER_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  final String VIBRATION_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26aa";
  final String ALARM_CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26ac";

  BluetoothCharacteristic? _userCharacteristic;
  BluetoothCharacteristic? _ledCharacteristic;
  BluetoothCharacteristic? _buzzerCharacteristic;
  BluetoothCharacteristic? _vibrationCharacteristic;

  BluetoothCharacteristic? _alarmCharacteristic;

  @override
  void initState() {
    super.initState();
    _connectedDevice = widget.connectedDevice;
    _getUserId();
    _connectToDevice();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getUserId() async {
    try {
      _userId = await MongoDatabase.obtenerUsuarioAct();
      if (_userId == null) throw Exception("UserID nulo");
    } catch (e) {
      debugPrint("Error al obtener el usuario actual: $e");
    }
  }

  Future<void> _connectToDevice() async {
    if (widget.connectedDevice == null) {
      debugPrint("No hay dispositivo conectado");
      return;
    }

    // Verificar conexión primero
    if (!widget.connectedDevice!.isConnected) {
      await widget.connectedDevice!.connect();
    }

    try {
      // Descubrir servicios
      List<BluetoothService> services =
          await widget.connectedDevice!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == USER_CHARACTERISTIC_UUID) {
              _userCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() ==
                LED_CHARACTERISTIC_UUID) {
              _ledCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() ==
                BUZZER_CHARACTERISTIC_UUID) {
              _buzzerCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() ==
                VIBRATION_CHARACTERISTIC_UUID) {
              _vibrationCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() ==
                ALARM_CHARACTERISTIC_UUID) {
              _alarmCharacteristic = characteristic;
            }
          }
        }
      }

      setState(() {
        _deviceState = true;
      });

      // Asignar usuario
      if (_userCharacteristic?.properties.write ?? false) {
        await _writeUser();
      }

      // Leer estados iniciales
      _readInitialStates();
    } catch (e) {
      debugPrint("Error al conectar con el dispositivo: $e");
    }
  }

  _writeUser() async {
    if (_userId == null || _userId!.isEmpty) {
      debugPrint("Error: UserID no válido");
      return;
    }
    if (_userCharacteristic == null) {
      debugPrint("Característica de usuario no encontrada");
      return;
    }
    try {
      final bytes = utf8.encode(_userId!);
      await _userCharacteristic!.write(bytes);
      debugPrint("Usuario enviado");
    } catch (e) {
      debugPrint("Error escribiendo UserID: $e");
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

      if (_alarmCharacteristic != null &&
          _alarmCharacteristic!.properties.read) {
        final value = await _alarmCharacteristic!.read();
        setState(() {
          _alarmState = value[0] > 0;
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
        debugPrint("LED ${value ? 'habilitado' : 'deshabilitado'}");
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
        debugPrint("Sonido ${value ? 'habilitado' : 'deshabilitado'}");
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
        debugPrint("Vibración ${value ? 'habilitada' : 'deshabilitada'}");
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

  Future<void> _toggleAlarm(bool value) async {
    if (_alarmCharacteristic != null &&
        _alarmCharacteristic!.properties.write) {
      try {
        await _alarmCharacteristic!.write([value ? 1 : 0]);
        setState(() {
          _alarmState = value;
        });
        debugPrint("Alarma ${value ? 'activada' : 'desactivada'}");
      } catch (e) {
        debugPrint("Error al cambiar el estado de la alarma: $e");
      }
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
          child: Icon(icon, color: Colors.black),
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
        backgroundColor: const Color(0xFF001D47),
        elevation: 0,
        actions: [
          ProfileBtn(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                "Configura el dispositivo según tus necesidades!",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Color(0xFF1B2727),
                ),
              ),
              const SizedBox(height: 32),
              _buildControlTile(
                title: "Alerta",
                subtitle: "Habilitar/Deshabilitar",
                icon: Icons.crisis_alert,
                value: _deviceState,
                onChanged: _toggleDevice,
              ),
              _buildControlTile(
                title: "Led indicador",
                subtitle: "Habilitar/Deshabilitar",
                icon: Icons.lightbulb_outline,
                value: _ledState,
                onChanged: _toggleLed,
                enabled: _deviceState,
              ),
              _buildControlTile(
                title: "Sonido",
                subtitle: "Habilitar/Deshabilitar",
                icon: Icons.volume_up_outlined,
                value: _buzzerState,
                onChanged: _toggleBuzzer,
                enabled: _deviceState,
              ),
              _buildControlTile(
                title: "Vibración",
                subtitle: "Habilitar/Deshabilitar",
                icon: Icons.vibration,
                value: _vibrationState,
                onChanged: _toggleVibration,
                enabled: _deviceState,
              ),
              ElevatedButton(onPressed: (){
                if (_alarmState){
                  _toggleAlarm;
                } else if (!_alarmState){
                  debugPrint("La alarma se encuentra apagada");
                }
              }, child: const Text("Apagar alarma")),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Bottom(connectedDevice: _connectedDevice),
    );
  }
}
