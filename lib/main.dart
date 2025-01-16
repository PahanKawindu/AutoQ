import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_flutter1/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(247, 45, 56, 197),
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home:  WelcomeScreen()
    );
  }
}
