import 'package:flutter/material.dart';
import 'package:vitasphere1/widgets/app.dart';

import 'db/database.dart';

void main() async {
  await MongoDatabase.connect();
  runApp(const App());
}
