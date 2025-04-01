import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection collection;
  static late DbCollection registers;
  static bool isConnected = false;
  static bool isConnected2 = false;

  static const MONGO_URL =
      "mongodb+srv://arturo2005sidas:Sidas-200@vitasphere.nvtg2.mongodb.net/VitaSphere?retryWrites=true&w=majority";
  static const COLLECTION_NAME = "Users";

  static const COLLECTION_METRIC = "Registro";
  static const String SECRET_KEY = "vita";

  static Future<void> connect() async {

    if (isConnected && isConnected2) return;

    while (!isConnected || !isConnected2) {
      try {
        db = await Db.create(MONGO_URL);
        await db.open();
        collection = db.collection(COLLECTION_NAME);
        isConnected = true;
        debugPrint("Conexión exitosa a Usuarios");
      } catch (e) {
        debugPrint("Error en la conexión: $e");
      }
      try {
        db = await Db.create(MONGO_URL);
        await db.open();
        registers = db.collection(COLLECTION_METRIC);
        isConnected2 = true;
        debugPrint("Conexión exitosa a Registros");
      } catch (e) {
        debugPrint("Error en la conexión: $e");
      }
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

      String storedPassword = user[
          "password"]; // Extraer contraseñas almacenadas en la base de datos

      String hashedPassword = encriptarPassword(
          password); // Encriptar la contraseña ingresada para compararla

      // Comparar con la base de datos
      if (hashedPassword == storedPassword) {
        debugPrint(
            "Inicio de sesión exitoso para: ${user['email']}"); // Confirmación de inicio de sesión

        SharedPreferences prefs = await SharedPreferences
            .getInstance(); // Obtener instancia de SharedPreferences

        try {
          String userId = (user["_id"] as ObjectId)
              .oid; // Obtener el id del usuario desde base de datos
          await prefs.setString(
              "user_id", userId); // Guardar id del usuario en SharedPreferences
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
    String? user =  prefs.getString("user_id");
    if (user == null) {
      debugPrint("El usuario es nulo");
    }
    return user;
  }

  static Future<void> ligarDispositivo(String deviceName) async {
    String? appUser = await obtenerUsuarioAct();

    var objectId = ObjectId.parse(appUser!);

    var result = await collection.updateOne(
      {
        "_id": objectId,
        "dispositivos.modelo": deviceName // Busca si el dispositivo ya existe
      },
      {
        "\$set": {
          "dispositivos.\$.estado": "activo" // Si existe, actualiza su estado
        }
      },
    );

    if (result.nModified == 0) {
      // Verifica si el dispositivo ya existe con el mismo estado activo
      var existing = await collection.findOne({
        "_id": objectId,
        "dispositivos": {
          "\$elemMatch": {"modelo": deviceName, "estado": "activo"}
        }
      });

      if (existing == null) {
        // Si no existe un dispositivo con el mismo modelo y estado, se agrega
        await collection.updateOne(
          {"_id": objectId},
          {
            "\$push": {
              "dispositivos": {"modelo": deviceName, "estado": "activo"}
            }
          },
        );
        debugPrint("Dispositivo agregado.");
      } else {
        debugPrint("Dispositivo ya está registrado con el estado activo.");
      }
    } else {
      debugPrint("Dispositivo actualizado.");
    }
  }

  static Future<String> obtenerNombre() async {
    String? id = await obtenerUsuarioAct();
    String? nombre;
    Map<String, dynamic>? datusu;
    try {
      ObjectId lol = ObjectId.parse(id!);
      datusu = await collection.findOne({"_id": lol});
      nombre = datusu?["nombre"];
    } catch (e) {
      debugPrint("No se encontró el nombre: $e");
    }
    return nombre ?? "Usuario";
  }

  static Future<Map<String, dynamic>?> ultmetrica() async {
    try {
      String? appUser = await obtenerUsuarioAct();
      var objectId = ObjectId.parse(appUser!);

      await connect();
      var ultimaMetrica = registers.modernFind(
        filter: {"tipo": "Metricas", "id_user": appUser},
        sort: {"_id": -1},
        limit: 1,
      );
      var caidas = registers.modernFind(
        filter: {"tipo": "Alerta", "categoria": "caida", "id_user": appUser},
      );

      Map<String, dynamic> resultado = await ultimaMetrica.first;
      resultado["caidas"] = caidas.length;

      return resultado;
    } catch (e) {
      debugPrint("Error al obtener la última métrica y caídas: $e");
      return null;
    }
  }
}
