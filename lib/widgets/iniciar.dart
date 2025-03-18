import 'package:flutter/material.dart';
import 'package:vitasphere1/widgets/registrar.dart';
import '../db/database.dart';
import 'package:vitasphere1/screens/pair.dart';
import 'package:google_fonts/google_fonts.dart';

class Iniciar extends StatefulWidget {
  const Iniciar({super.key});

  @override
  State<Iniciar> createState() => _IniciarState();
}

class _IniciarState extends State<Iniciar> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // Para controlar la visibilidad de la contraseña

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await MongoDatabase.connect();
    });
  }

  Future<void> iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      bool esValido = await MongoDatabase.verificarUsuario(email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esValido ? "✅ Inicio de sesión exitoso" : "❌ Email o contraseña incorrectos",
            style: const TextStyle(color: Color(0xFFB0B8CF)),
          ),
          backgroundColor: esValido ? Color(0xFF6B8E4E) : Colors.black,
        ),
      );

      if (esValido) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Pair(),));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5DDDF),
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
                    "Hola de nuevo!",
                    style: GoogleFonts.quicksand(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3c5148),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Inicie sesión para acceder a su cuenta",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1B2727),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Correo electrónico", emailController, isEmail: true),
                  const SizedBox(height: 15),
                  _buildPasswordField(),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2727),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFFB0B8CF))
                          : const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB0B8CF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Registrar(),));
                    },
                    child: const Text(
                      "¿No tienes una cuenta aún?",
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
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
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
        return null;
      },
    );
  }
}
