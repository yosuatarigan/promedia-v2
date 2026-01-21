import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:promedia_v2/admin_dashboard.dart';
import 'package:promedia_v2/firebase_config.dart';
import 'package:promedia_v2/splashscreen.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  WidgetsFlutterBinding.ensureInitialized();
  kIsWeb ? await FirebaseConfig.initialize() : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Promedia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD81B60),
          primary: const Color(0xFFD81B60),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
            headlineMedium: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD81B60),
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD81B60),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      home: Splashscreen(),
    );
  }
}
