// apps/customer/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/auth_provider.dart';
import '../features/home/home_screen.dart';
import '../features/rides/ride_booking.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/rides/booking',
        builder: (context, state) => const RideBookingScreen(),
      ),
      GoRoute(
        path: '/menu/:merchantId',
        builder: (context, state) {
          final merchantId = state.pathParameters['merchantId'] ?? '';
          return MenuScreen(merchantId: merchantId);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
        redirect: (context, state) {
          // [CRITICAL AUTH WALL]: Check if user is logged in
          final isAuthenticated = ref.read(isAuthenticatedProvider);
          if (!isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route error: ${state.error}'),
      ),
    ),
  );
});

// Skeleton feature widgets to keep compilation layout intact
class MenuScreen extends StatelessWidget {
  final String merchantId;
  const MenuScreen({Key? key, required this.merchantId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Menu of merchant: $merchantId')));
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Checkout')));
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                elevation: 8.0,
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium App Branding
                      Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Color(0xFF7C3AED),
                          size: 36.0,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'SHAHGANJ.ONLINE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Digital Network of Rural Shahganj',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32.0),

                      if (user == null) ...[
                        // Auth Trigger Mode
                        ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(authNotifierProvider.notifier).signInWithGoogleMock();
                            if (context.mounted) {
                              context.go('/');
                            }
                          },
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: Text(
                            'Sign In with Google',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            minimumSize: const Size(double.infinity, 54.0),
                            elevation: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Google Sign-In is required to secure orders and payments.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        // Active user state info
                        CircleAvatar(
                          radius: 36.0,
                          backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                          child: user.avatar == null ? const Icon(Icons.person, size: 36.0) : null,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Welcome, ${user.displayName}!',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.go('/');
                          },
                          icon: const Icon(Icons.explore, color: Colors.white),
                          label: Text(
                            'Explore Services',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981), // success green
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authNotifierProvider.notifier).signOut();
                          },
                          icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                          label: Text(
                            'Sign Out',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
