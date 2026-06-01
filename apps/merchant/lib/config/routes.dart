// apps/merchant/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_provider.dart';
import '../features/onboarding/onboarding_wizard.dart';
import '../features/dashboard/pending_screen.dart';

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

class RiderHomeScreen extends ConsumerWidget {
  const RiderHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rider = ref.watch(activeRiderProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(rider?.name ?? 'Rider Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome Rider! Active Deliveries Screen.'),
      ),
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
