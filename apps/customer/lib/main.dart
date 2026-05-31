import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Asia-South1, native Blaze config)
  await Firebase.initializeApp();
  
  // Initialize Hive Offline Caches
  await Hive.initFlutter();
  await Hive.openBox('guest_cart');
  await Hive.openBox('user_preferences');

  runApp(
    const ProviderScope(
      child: ShahganjCustomerApp(),
    ),
  );
}

class ShahganjCustomerApp extends ConsumerWidget {
  const ShahganjCustomerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Shahganj.online',
      debugShowCheckedModeBanner: false,
      
      // Design System Theme Tokens (Section 12 of Master Spec)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF7C3AED),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFF8B5CF6),
          background: Color(0xFFFFFFFF),
          surface: Color(0xFFF3F4F6),
          error: Color(0xFFEF4444),
        ),
        
        // Font families definitions
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
          headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        
        // Shapes CardRadius=16, ButtonRadius=12
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2.0,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          ),
        ),
      ),
      
      routerConfig: router,
    );
  }
}
