import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import shell layouts or feature screens (mocks/skeletons for scaffold build)
// In production, these import the exact feature widgets
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
          // [CRITICAL AUTH WALL]: Guest Mode visitor auth redirect (Section 10 Phase 2)
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            // Returns path redirecting to visitor auth screen/modal
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Google Sign-In Platform')));
}
