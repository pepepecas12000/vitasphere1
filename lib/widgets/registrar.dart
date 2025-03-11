import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import '../db/database.dart';

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

  Future<void> insertarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (MongoDatabase.collection == null) {
          print("❌ Error: La colección no está inicializada.");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ No se puede conectar a la base de datos")),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Verificar si el email ya está registrado
        var existingUser = await MongoDatabase.collection.findOne({
          "email": emailController.text.trim(),
        });

        if (existingUser != null) {
          print("❌ El usuario ya existe.");
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
          "password": hashedPassword, // Contraseña encriptada
          "confpassword": hashedPassword, // También en la confirmación si es necesario
          "fecha": fechaController.text.trim(),
        };

        var result = await MongoDatabase.collection.insertOne(nuevoUsuario);
        setState(() => _isLoading = false);

        if (result.isSuccess) {
          print("✅ Usuario insertado con éxito");

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
        print("❌ Error al insertar usuario: $e");
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
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Nombre", nombreController),
              _buildTextField("Apellidos", apellidosController),
              _buildTextField("Teléfono", telefonoController, isPhone: true),
              _buildTextField("Email", emailController, isEmail: true),
              _buildTextField("Contraseña", passwordController, obscureText: true),
              _buildTextField("Fecha de Nacimiento (YYYY-MM-DD)", fechaController),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : insertarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Registrar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
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
