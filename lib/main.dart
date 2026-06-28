import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:micro_society_app/app.dart';
import 'package:micro_society_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MicroSocietyApp());
}
