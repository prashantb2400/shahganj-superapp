// apps/merchant/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_models/core_models.dart';
import 'package:firebase_sdk/firebase_sdk.dart';
import '../features/auth/auth_provider.dart';
import '../features/onboarding/onboarding_wizard.dart';
import '../features/dashboard/pending_screen.dart';
import '../features/rider/rider_dispatch_overlay.dart';
import '../features/rider/rider_delivery_map.dart';
import '../features/rider/rider_location_service.dart';
import '../features/rider/rider_earnings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGateway(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingWizard(),
      ),
      GoRoute(
        path: '/pending',
        builder: (context, state) => const PendingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MerchantDashboard(),
      ),
      GoRoute(
        path: '/rider/home',
        builder: (context, state) => const RiderHomeScreen(),
      ),
      GoRoute(
        path: '/rider/earnings',
        builder: (context, state) => const RiderEarningsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Console Route Error: ${state.error}'),
      ),
    ),
  );
});

/// [CRITICAL GATEWAY]: Decides initial screen based on active role and status
class AuthGateway extends ConsumerWidget {
  const AuthGateway({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    final merchant = ref.watch(activeMerchantProvider);
    final rider = ref.watch(activeRiderProvider);

    if (user == null) {
      return const LoginScreen();
    }

    if (user.role == 'rider' || rider != null) {
      return const RiderHomeScreen();
    }

    if (merchant == null) {
      return const OnboardingWizard();
    }

    if (merchant.status == 'pending') {
      return const PendingScreen();
    }

    return const MerchantDashboard();
  }
}

// Temporary shells for compilation validation
class MerchantDashboard extends ConsumerWidget {
  const MerchantDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final merchant = ref.watch(activeMerchantProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant?.businessName ?? 'Merchant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to your Merchant Console Dashboard!'),
      ),
    );
  }
}

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifyingOtp = false;
  bool _isLocationSyncing = false;

  Future<void> _toggleLocationSync(String riderId) async {
    try {
      if (_isLocationSyncing) {
        await RiderLocationService().stopSync(riderId);
        setState(() => _isLocationSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🛰️ Location Sync Stopped. Offline.')),
        );
      } else {
        await RiderLocationService().startSync(riderId);
        setState(() => _isLocationSyncing = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF10B981),
            content: Text('🛰️ Location Sync Started. Live Kalman GPS active!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: const Color(0xFFEF4444), content: Text('Error starting sync: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider);
    final rider = ref.watch(activeRiderProvider);

    if (user == null || rider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Stream deliveries active queue for this rider
    final deliveriesStream = ref.watch(riderDeliveriesStreamProvider(user.uid));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Rider Dark mode primary background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.two_wheeler, color: Color(0xFF10B981)),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.name,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'E-Rickshaw Active • ${rider.phone}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.0),
                )
              ],
            )
          ],
        ),
        actions: [
          // Live Kalman GPS Status Toggle (Rule 11 & 27)
          IconButton(
            icon: Icon(
              _isLocationSyncing ? Icons.gps_fixed : Icons.gps_off,
              color: _isLocationSyncing ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
            onPressed: () => _toggleLocationSync(user.uid),
            tooltip: 'Live Kalman GPS Sync',
          ),
          // Wallet/Earnings (Phase 5)
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            onPressed: () => GoRouter.of(context).push('/rider/earnings'),
            tooltip: 'Earnings & Metrics',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          )
        ],
      ),
      body: deliveriesStream.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.two_wheeler, size: 80.0, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16.0),
                  Text(
                    'No Active Deliveries',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Waiting for incoming captive dispatches...',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }

          // Fetch the first active order
          final order = deliveries.first;

          // [CRITICAL OVERLAY]: If order is assigned (confirmed state), show dispatch accept overlay!
          if (order.status == 'confirmed') {
            return RiderDispatchOverlay(
              order: order,
              riderId: user.uid,
              onDismiss: () {
                // Instantly re-stream updates
              },
            );
          }

          // Active journey flow (preparing, ready, picked_up)
          final bool isPickedUp = order.status == 'picked_up';

          return Column(
            children: [
              // 1. Live openstreetmap routing panel
              Expanded(
                flex: 3,
                child: RiderDeliveryMap(
                  riderLat: rider.latitude ?? 26.0125,
                  riderLng: rider.longitude ?? 82.6890,
                  destLat: order.deliveryAddress.latitude,
                  destLng: order.deliveryAddress.longitude,
                  destinationAddress: order.deliveryAddress.formattedAddress,
                ),
              ),

              // 2. Active Handoff actions card
              Card(
                margin: const EdgeInsets.all(16.0),
                color: const Color(0xFF1E293B),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ORDER #${order.id.substring(0, 8).toUpperCase()}',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 10.0, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Customer Address: ${order.deliveryAddress.formattedAddress}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Total Payable: ₹${order.totals.total} (UPI Quick Pay)',
                        style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13.0),
                      ),
                      const SizedBox(height: 20.0),

                      // Action button state machine
                      if (!isPickedUp) ...[\n                        ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(order.id, 'picked_up'),
                          icon: const Icon(Icons.local_shipping, color: Colors.white),
                          label: Text(
                            'MARK AS PICKED UP',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                        ),
                      ] else ...[\n                        ElevatedButton.icon(
                          onPressed: () => _showOtpVerificationDialog(context, order),
                          icon: const Icon(Icons.verified, color: Colors.white),
                          label: Text(
                            'VERIFY DELIVERY OTP',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Simple status updates for pickup handoffs
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await ref.read(orderRepositoryProvider).updateOrderStatus(orderId, newStatus, notes: 'Rider picked up order from store.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully!')),
      );
    } catch (e) {
      print("❌ Update status error: $e");
    }
  }

  /// Displays the delivery secure OTP handoff dialogue card
  void _showOtpVerificationDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              title: Text(
                'Customer Delivery OTP',
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Input the 4-digit secure OTP code shown on the customer mobile screen to verify final handoff.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.0),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 24.0, letterSpacing: 8.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      counterText: '',
                      hintText: '0000',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL', style: TextStyle(color: Color(0xFFEF4444))),
                ),
                ElevatedButton(
                  onPressed: _isVerifyingOtp ? null : () async {
                    setDialogState(() => _isVerifyingOtp = true);
                    final isOk = await ref.read(orderRepositoryProvider).verifyDeliveryOtp(order.id, _otpController.text);
                    setDialogState(() => _isVerifyingOtp = false);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      if (isOk) {
                        // Success handoff, free up rider
                        await FirebaseFirestore.instance.collection('riders').doc(order.riderId).update({
                          'status': 'available',
                        });
                        _otpController.clear();
                        ScaffoldMessenger.of(ref.context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF10B981),
                            content: Text('🎉 OTP Verified! Delivery marked success. Safe drive!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(ref.context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFFEF4444),
                            content: Text('❌ Invalid Delivery OTP! Handoff denied.'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: _isVerifyingOtp 
                      ? const SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                      : const Text('VERIFY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _inviteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront, size: 56.0, color: Color(0xFF7C3AED)),
                    const SizedBox(height: 16.0),
                    Text(
                      'SHAHGANJ PARTNERS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF7C3AED),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF7C3AED),
                      tabs: const [
                        Tab(text: 'Merchant Sign-In'),
                        Tab(text: 'Rider Sign-In'),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      height: 280.0,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Merchant login
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Authorized Google Account is required to open a digital shop branch.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 32.0),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await ref.read(authNotifierProvider.notifier).signInWithGoogleMerchantMock();
                                },
                                icon: const Icon(Icons.login, color: Colors.white),
                                label: const Text('Connect with Google', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  minimumSize: const Size(double.infinity, 50.0),
                                ),
                              ),
                            ],
                          ),
                          // Tab 2: Rider login
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                  prefixText: '+91 ',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: _inviteController,
                                decoration: const InputDecoration(
                                  labelText: 'Merchant Invite Code',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              ElevatedButton(
                                onPressed: _isLoading ? null : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await ref.read(authNotifierProvider.notifier).signInWithPhoneRiderMock(
                                      _phoneController.text,
                                      _inviteController.text,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    setState(() => _isLoading = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981), // success green
                                  minimumSize: const Size(double.infinity, 50.0),
                                ),
                                child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Verify Phone & Sign-In', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
