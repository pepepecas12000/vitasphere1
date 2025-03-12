import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection collection;
  static bool isConnected = false;

  static const MONGO_URL =
      "mongodb+srv://arturo2005sidas:Sidas-200@vitasphere.nvtg2.mongodb.net/VitaSphere?retryWrites=true&w=majority";
  static const COLLECTION_NAME = "Users";
  static const String SECRET_KEY = "vitasphere";

  static Future<void> connect() async {
    if (isConnected) return;
    try {
      db = await Db.create(MONGO_URL);
      await db.open();
      collection = db.collection(COLLECTION_NAME);
      isConnected = true;
      print("✅ Conexión exitosa a MongoDB Atlas");
    } catch (e) {
      print("❌ Error en la conexión a MongoDB: $e");
    }
  }

  /// **Encriptar contraseña con HMAC-SHA256**
  static String encriptarPassword(String password) {
    var key = utf8.encode(SECRET_KEY);
    var bytes = utf8.encode(password);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  /// **Registrar un nuevo usuario en MongoDB**
  static Future<bool> registrarUsuario(
      String nombre, String apellidos, String telefono, String email, String password, String fecha) async {
    try {
      print("📝 Intentando registrar usuario con email: $email");

      // Verificar si el usuario ya existe
      var existingUser = await collection.findOne({"email": email});
      if (existingUser != null) {
        print("❌ El usuario ya existe.");
        return false;
      }

      // Encriptar la contraseña antes de guardarla
      String hashedPassword = encriptarPassword(password);

      var nuevoUsuario = {
        "_id": ObjectId(),
        "nombre": nombre.trim(),
        "apellidos": apellidos.trim(),
        "telefono": telefono.trim(),
        "email": email.trim(),
        "password": hashedPassword, // Contraseña encriptada
        "confpassword": hashedPassword, // Para validación extra si es necesario
        "fecha": fecha.trim(),
      };

      var result = await collection.insertOne(nuevoUsuario);

      if (result.isSuccess) {
        print("✅ Usuario registrado con éxito.");
        return true;
      } else {
        print("❌ Error al registrar usuario.");
        return false;
      }
    } catch (e) {
      print("❌ Error inesperado al registrar usuario: $e");
      return false;
    }
  }

  /// **Verificar usuario y contraseña en MongoDB**
  static Future<bool> verificarUsuario(String email, String password) async {
    try {
      print("🔎 Buscando usuario con correo: $email");

      var user = await collection.findOne({
        "email": {"\$regex": "^${RegExp.escape(email)}\$", "\$options": "i"}
      });

      if (user == null) {
        print("❌ Usuario no encontrado.");
        return false;
      }

      print("✅ Usuario encontrado: ${user['email']}");

      // Extraer contraseñas almacenadas en la base de datos
      String storedPassword = user["password"];
      String storedConfPassword = user["confpassword"];

      // Encriptar la contraseña ingresada para compararla
      String hashedPassword = encriptarPassword(password);

      // Comparar con la base de datos
      if (hashedPassword == storedPassword || hashedPassword == storedConfPassword) {
        print("✅ Inicio de sesión exitoso para: ${user['email']}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_email", email);
        return true;
      } else {
        print("❌ Contraseña incorrecta.");
        return false;
      }
    } catch (e) {
      print("❌ Error inesperado al verificar usuario: $e");
      return false;
    }
  }

  static Future<void> cerrarSesion() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_email");
  }

  static Future<String?> obtenerUsuarioAct() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_email");

  }
}
