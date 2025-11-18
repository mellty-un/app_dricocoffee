import 'package:application_pos_dricocoffee/pages/auth/sign_in_pages.dart';
import 'package:application_pos_dricocoffee/pages/splash_screen.dart';
import 'package:application_pos_dricocoffee/services/supabase_client_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drico Coffee POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(), 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SignInPages(),
    );
  }
}