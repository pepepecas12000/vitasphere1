import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/monitor.dart';
import '../db/database.dart';
import 'iniciar.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String? _userId;

  getUser() async {
    _userId = await MongoDatabase.obtenerUsuarioAct();
  }

  dbConnect() async {
    await MongoDatabase.connect();
  }

  void redirect() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _userId != null ? Monitor() : const Iniciar(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUser();
    dbConnect();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF032F6C),
              Color(0xFF084A98),
              Color(0xFF137ABC),
              Color(0xFF28B9E8),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("resources/images/vitasphere-logo.png",
                  width: 120, height: 120),
              const SizedBox(height: 30),
              Text(
                "VitaSphere",
                style: GoogleFonts.quicksand(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: 0.9,
                child: Text(
                  "Alerta inteligente, cuidado inmediato",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
