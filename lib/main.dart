import 'package:application_pos_dricocoffee/pages/auth/splash_screen.dart';
import 'package:application_pos_dricocoffee/pages/customer/customer_histori_pages.dart';
import 'package:application_pos_dricocoffee/providers/cart_providers.dart';
import 'package:application_pos_dricocoffee/providers/category_providers.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D3E50)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/customer-history': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
          return CustomerHistoriPages(
            customerId: args['customerId'] ?? 0,
            customerName: args['customerName'] ?? 'Customer',
          );
        },
      },
    );
  }
}