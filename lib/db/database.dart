import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection collection;
  static bool isConnected = false;

  static const MONGO_URL =
      "mongodb+srv://arturo2005sidas:Sidas-200@vitasphere.nvtg2.mongodb.net/VitaSphere?retryWrites=true&w=majority";
  static const COLLECTION_NAME = "Users";
  static const String SECRET_KEY = "vita";

  static Future<void> connect() async {
    if (isConnected) return;
    try {
      db = await Db.create(MONGO_URL);
      await db.open();
      collection = db.collection(COLLECTION_NAME);
      isConnected = true;
      debugPrint("Conexión exitosa a MongoDB Atlas");
    } catch (e) {
      debugPrint("Error en la conexión a MongoDB: $e");
    }
  }

  // Encriptar contraseña con HMAC-SHA256
  static String encriptarPassword(String password) {
    var key = utf8.encode(SECRET_KEY);
    var bytes = utf8.encode(password);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  // Registrar un nuevo usuario en MongoDB
  static Future<bool> registrarUsuario(
      String nombre,
      String apellidos,
      String tel,
      String email,
      String password,
      String fecha,
      String sexo) async {
    try {
      debugPrint("📝Intentando registrar usuario con email: $email");

      // Verificar si el usuario ya existe
      var existingUser = await collection.findOne({"email": email});
      if (existingUser != null) {
        debugPrint("El usuario ya existe.");
        return false;
      }

      if (password == "") {
        debugPrint("La contraseña no puede estar vacía.");
        return false;
      }

      // Encriptar la contraseña antes de guardarla
      String hashedPassword = encriptarPassword(password);

      var nuevoUsuario = {
        "_id": ObjectId(),
        "nombre": nombre.trim(),
        "apellidos": apellidos.trim(),
        "telefono": tel.trim(),
        "email": email.trim(),
        "sexo": sexo.trim(),
        "password": hashedPassword,
        "fecha": fecha.trim(),
        "estado": "activo",
      };

      var result = await collection.insertOne(nuevoUsuario);

      if (result.isSuccess) {
        debugPrint("Usuario registrado con éxito.");
        return true;
      } else {
        debugPrint("Error al registrar usuario.");
        return false;
      }
    } catch (e) {
      debugPrint("Error inesperado al registrar usuario: $e");
      return false;
    }
  }

  // Verificar usuario y contraseña en MongoDB
  static Future<bool> verificarUsuario(String email, String password) async {
    try {
      debugPrint("🔎Buscando usuario con correo: $email");

      var user = await collection.findOne({"email": email.trim()});

      if (user == null) {
        debugPrint("Usuario no encontrado.");
        return false;
      }

      debugPrint("Usuario encontrado: ${user['email']}");

      // Extraer el estado del usuario
      String estado = user["estado"];

      if (estado == "inactivo") {
        debugPrint("Usuario inactivo.");
        return false;
      }

      String storedPassword = user["password"]; // Extraer contraseñas almacenadas en la base de datos

      String hashedPassword = encriptarPassword(password); // Encriptar la contraseña ingresada para compararla

      // Comparar con la base de datos
      if (hashedPassword == storedPassword) {

        debugPrint("Inicio de sesión exitoso para: ${user['email']}"); // Confirmación de inicio de sesión

        SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtener instancia de SharedPreferences

        try {
          String userId = user["_id"].toString();  // Obtener desde base de datos el id del usuario
          await prefs.setString("user_id", userId); // Guardar id del usuario en SharedPreferences
          return true;
        } catch (e) {
          debugPrint("Error al guardar el ID: $e");
          return false;
        }

      } else {
        debugPrint("Contraseña incorrecta.");
        return false;
      }
    } catch (e) {
      debugPrint("Error inesperado al verificar usuario: $e");
      return false;
    }
  }

  static Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_id");
  }

  static Future<String?> obtenerUsuarioAct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }
}
