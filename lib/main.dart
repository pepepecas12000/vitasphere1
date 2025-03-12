import 'package:flutter/material.dart';
import 'package:vitasphere1/widgets/app.dart';

import 'db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  String? userEmail = await MongoDatabase.obtenerUsuarioAct();
  runApp(App(userEmail: userEmail));
}
