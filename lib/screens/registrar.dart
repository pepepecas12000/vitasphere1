import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import '../db/database.dart';
import 'package:intl/intl.dart';

import 'iniciar.dart';

class Registrar extends StatefulWidget {
  const Registrar({super.key});

  @override
  State<Registrar> createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // Para controlar la visibilidad de la contraseña
  final List<String> _genero = ['Masculino', 'Femenino', 'Otro', 'Prefiero no decirlo'];
  String? _genSelected;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de fecha con formato
    fechaController.text = '';
  }

  // Función para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 años atrás por defecto
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3c5148), // Color principal
              onPrimary: Color(0xFFD5DDDF), // Color del texto sobre el color principal
              onSurface: Color(0xFF3c5148), // Color del texto en la superficie
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3c5148), // Color de los botones de texto
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formatear la fecha seleccionada
        fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> insertarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        var existingUser = await MongoDatabase.collection.findOne({
          "email": emailController.text.trim(),
        });

        if (existingUser != null) {
          debugPrint("❌ El usuario ya existe.");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ El email ya está en uso")),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Encriptar la contraseña antes de almacenarla
        String hashedPassword = MongoDatabase.encriptarPassword(passwordController.text.trim());

        var nuevoUsuario = {
          "_id": ObjectId(),
          "nombre": nombreController.text.trim(),
          "apellidos": apellidosController.text.trim(),
          "telefono": telefonoController.text.trim(),
          "email": emailController.text.trim(),
          "sexo": _genSelected,
          "password": hashedPassword, // Contraseña encriptada
          "confpassword": hashedPassword, // También en la confirmación si es necesario
          "fecha": fechaController.text.trim(),
        };

        var result = await MongoDatabase.collection.insertOne(nuevoUsuario);
        setState(() => _isLoading = false);

        if (result.isSuccess) {
          debugPrint("✅ Usuario insertado con éxito");

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Usuario registrado con éxito")),
          );

          // Redirigir al inicio de sesión después del registro
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Error al registrar usuario")),
          );
        }
      } catch (e) {
        debugPrint("❌ Error al insertar usuario: $e");
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error inesperado: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5DDDF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3c5148)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Crea una cuenta!",
                    style: GoogleFonts.quicksand(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3c5148),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Regístrate para comenzar",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1B2727),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Nombre(s)", nombreController),
                  const SizedBox(height: 10),
                  _buildTextField("Apellido(s)", apellidosController),
                  const SizedBox(height: 10),
                  _buildDateField(),
                  const SizedBox(height: 10),
                  _buildGenderDropdown(),
                  const SizedBox(height: 10),
                  _buildTextField("Número de celular", telefonoController, isPhone: true),
                  const SizedBox(height: 10),
                  _buildTextField("Correo electrónico", emailController, isEmail: true),
                  const SizedBox(height: 10),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : insertarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2727),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFFD5DDDF))
                          : const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Iniciar(),));
                    },
                    child: const Text(
                      "¿Ya tienes una cuenta?",
                      style: TextStyle(color: Color(0xFF1B2727), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: fechaController,
      readOnly: true, // Hacer el campo de solo lectura
      style: GoogleFonts.roboto(
        color: const Color(0xFF1B2727),
      ),
      cursorColor: const Color(0xFF1B2727),
      decoration: InputDecoration(
        labelText: "Fecha de Nacimiento",
        labelStyle: GoogleFonts.roboto(
          color: const Color(0xFF1B2727),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B2727), width: 2),
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF3c5148),
          ),
          onPressed: () => _selectDate(context),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Seleccione su fecha de nacimiento";
        }
        return null;
      },
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Sexo",
        labelStyle: GoogleFonts.roboto(
          color: const Color(0xFF1B2727),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B2727), width: 2),
        ),
      ),
      style: GoogleFonts.roboto(
        color: const Color(0xFF1B2727),
      ),
      dropdownColor: Colors.white,
      value: _genSelected,
      items: _genero.map((opcion) =>
          DropdownMenuItem(
              value: opcion,
              child: Text(
                opcion,
                style: GoogleFonts.roboto(
                  color: const Color(0xFF1B2727),
                ),
              )
          )
      ).toList(),
      onChanged: (String? newOpt) {
        setState(() => _genSelected = newOpt);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Seleccione su sexo";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscureText,
      style: GoogleFonts.roboto(
        color: const Color(0xFF1B2727),
      ),
      cursorColor: const Color(0xFF1B2727),
      decoration: InputDecoration(
        labelText: "Contraseña",
        labelStyle: GoogleFonts.roboto(
          color: const Color(0xFF1B2727),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B2727), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF3c5148),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Ingrese su contraseña";
        // if (value.length < 6) return "La contraseña debe tener al menos 6 caracteres";
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : isPhone ? TextInputType.phone : TextInputType.text,
      style: GoogleFonts.roboto(
        color: const Color(0xFF1B2727),
      ),
      cursorColor: const Color(0xFF1B2727),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(
          color: const Color(0xFF1B2727),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B2727), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Ingrese su $label";
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Ingrese un correo válido";
        }
        if (isPhone && !RegExp(r'^\d{10,15}$').hasMatch(value)) {
          return "Ingrese un teléfono válido";
        }
        return null;
      },
    );
  }
}
