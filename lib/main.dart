import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zekink/firebase_options.dart';
import 'package:zekink/onboarding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ZekinkApp());
}

class ZekinkApp extends StatelessWidget {
  const ZekinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5F7DFF),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Zekink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            overlayColor: Color.fromARGB(255, 30, 69, 161),
          ),
        ),
        primarySwatch: Colors.indigo,
        primaryColor: Color.fromARGB(255, 30, 69, 161),
        fontFamily: 'Arial',
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromARGB(255, 30, 69, 161),
          textTheme: ButtonTextTheme.primary,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 30, 69, 161),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 30, 69, 161)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 30, 69, 161)),
          ),
          hintStyle: TextStyle(color: Color.fromARGB(255, 30, 69, 161).withOpacity(0.6)),
        ),

        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: OnboardingScreen(),
    );
  }
}