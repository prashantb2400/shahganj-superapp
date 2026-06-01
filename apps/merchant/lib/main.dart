// apps/merchant/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/routes.dart';
import 'features/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Blaze environment)
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: ShahganjMerchantApp(),
    ),
  );
}

class ShahganjMerchantApp extends ConsumerWidget {
  const ShahganjMerchantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final user = ref.watch(authNotifierProvider);
    
    // Determine dynamic theme: Rider -> Dark Theme, Merchant -> Light Theme (Section 12 spec)
    final bool isRider = user != null && user.role == 'rider';

    return MaterialApp.router(
      title: 'Shahganj.online Console',
      debugShowCheckedModeBanner: false,
      
      // Dynamic Theming configuration based on Role spec
      theme: ThemeData(
        useMaterial3: true,
        brightness: isRider ? Brightness.dark : Brightness.light,
        
        // Primary brand colors
        primaryColor: isRider ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
        scaffoldBackgroundColor: isRider ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
        
        colorScheme: isRider 
          ? const ColorScheme.dark(
              primary: Color(0xFF10B981), // success green accents for riders
              secondary: Color(0xFF38BDF8),
              background: Color(0xFF0F172A),
              surface: Color(0xFF1E293B),
              error: Color(0xFFEF4444),
            )
          : const ColorScheme.light(
              primary: Color(0xFF7C3AED), // royal purple for merchants
              secondary: Color(0xFF8B5CF6),
              background: Color(0xFFFFFFFF),
              surface: Color(0xFFF3F4F6),
              error: Color(0xFFEF4444),
            ),

        // Custom fonts
        textTheme: GoogleFonts.interTextTheme(
          isRider ? ThemeData.dark().textTheme : ThemeData.light().textTheme
        ).copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
          headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),

        cardTheme: CardTheme(
          color: isRider ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: isRider ? 0.0 : 2.0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          ),
        ),
      ),
      
      routerConfig: router,
    );
  }
}
