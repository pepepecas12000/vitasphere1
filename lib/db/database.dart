import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';



class MongoDatabase {
  static late Db db;
  static late DbCollection collection;
  static late DbCollection Registros;
  static bool isConnected = false;
  static bool isConnected2 = false;

  static const MONGO_URL =
      "mongodb+srv://arturo2005sidas:Sidas-200@vitasphere.nvtg2.mongodb.net/VitaSphere?retryWrites=true&w=majority";
  static const COLLECTION_NAME = "Users";

  static const COLLECTION_METRIC = "Registro";
  static const String SECRET_KEY = "vita";

  static Future<void> connect() async {
    if (isConnected) return;
    try {
      db = await Db.create(MONGO_URL);
      await db.open();
      collection = db.collection(COLLECTION_NAME);
      isConnected = true;
      debugPrint("Conexión exitosa a MongoDB Atlas: Usuarios");


    } catch (e) {
      debugPrint("Error en la conexión a MongoDB: $e");
    }
    try {
      db = await Db.create(MONGO_URL);
      await db.open();
      Registros = db.collection(COLLECTION_METRIC);
      isConnected2 = true;
      debugPrint("✅ Conexión exitosa a MongoDB Atlas: Registros");
    } catch (e) {
      print("❌ Error en la conexión a MongoDB: $e");
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
    return prefs.getString("user_id");
  }

  static Future<void> ligarDispositivo(String deviceName) async {
    String? appUser = await obtenerUsuarioAct();

    if (appUser == null) {
      debugPrint("El usuario es nulo");
      return;
    }

    var objectId = ObjectId.parse(appUser);

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
          "\$elemMatch": { "modelo": deviceName, "estado": "activo" }
        }
      });

      if (existing == null) {
        // Si no existe un dispositivo con el mismo modelo y estado, se agrega
        await collection.updateOne(
          {"_id": objectId},
          {
            "\$push": {
              "dispositivos": { "modelo": deviceName, "estado": "activo" }
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
  
  static Future<String> obtenerNombre()async{
    String? id = await obtenerUsuarioAct();
    String? nombre;
    Map<String,dynamic?>? datusu;
    debugPrint("el id del usuario es el de: $id");
    try {

      ObjectId lol = ObjectId.parse(id!);
      debugPrint(lol.toString());

       datusu = await collection.findOne({"_id": lol});
       debugPrint(" esta es la cantidad $datusu?.length");
     nombre=datusu?["nombre"];
     debugPrint(" el nombre del cliente es $nombre");
    }catch(e){
      debugPrint("No se encontro el nombre: $e");
    }
    return nombre ?? "no";
  }

  static Future<Stream<Map<String, dynamic>>?> ultmetrica() async {
    try {
      var ultimaMetrica = await Registros.modernFind(filter:
      {"tipo": "Metricas"},sort: {"_id": -1}, limit:1 // Ordenar por _id en orden descendente (el más reciente primero)
      );

      return ultimaMetrica;
    } catch (e) {
      print("❌ Error al obtener la última métrica: $e");
      return null;
    }
  }
}
