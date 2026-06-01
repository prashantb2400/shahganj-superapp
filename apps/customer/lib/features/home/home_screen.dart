// apps/customer/lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:firebase_sdk/firebase_sdk.dart';
import '../auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider);
    final adsStream = ref.watch(activeAdsStreamProvider);
    final trendingMerchantsStream = ref.watch(merchantsByCategoryStreamProvider('restaurant'));

    // List of 8 core local services outlined in Section 10
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.restaurant, 'title': 'Food Delivery', 'route': '/menu/merchant_durbar_001'},
      {'icon': Icons.electric_bolt, 'title': 'Electrician', 'route': '/menu/merchant_guru_004'},
      {'icon': Icons.plumbing, 'title': 'Plumber', 'route': '/menu/merchant_alpha_005'},
      {'icon': Icons.face_retouching_natural, 'title': 'Beauty Care', 'route': '/menu/beauty_demo'},
      {'icon': Icons.local_hospital, 'title': 'OPD Clinic', 'route': '/menu/merchant_hospital_006'},
      {'icon': Icons.directions_car, 'title': 'Car Rental', 'route': '/menu/rental_demo'},
      {'icon': Icons.shopping_basket, 'title': 'Mart Delivery', 'route': '/menu/mart_demo'},
      {'icon': Icons.two_wheeler, 'title': 'E-Rickshaw', 'route': '/rides/booking'},
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SHAHGANJ.ONLINE',
              style: GoogleFonts.spaceGrotesk(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                fontSize: 22.0,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 14.0, color: theme.colorScheme.secondary),
                const SizedBox(width: 4.0),
                Text(
                  'Shahganj, Uttar Pradesh',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14.0,
              backgroundImage: (user != null && user.avatar != null) 
                  ? NetworkImage(user.avatar!) 
                  : null,
              child: (user == null || user.avatar == null) 
                  ? const Icon(Icons.account_circle_outlined, size: 28.0) 
                  : null,
            ),
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Dynamic Ads Banners Carousel
            adsStream.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: ShimmerList(itemCount: 1, itemHeight: 160.0),
              ),
              error: (err, stack) => _buildFallbackPromoBanner(theme),
              data: (ads) {
                if (ads.isEmpty) {
                  return _buildFallbackPromoBanner(theme);
                }
                return SizedBox(
                  height: 180.0,
                  child: PageView.builder(
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return GestureDetector(
                        onTap: () {
                          // Standard route routing based on spec deepLinks
                          if (ad.deepLink.contains('/rides/booking')) {
                            context.push('/rides/booking');
                          } else if (ad.deepLink.contains('/menu/')) {
                            final mId = ad.deepLink.split('/menu/').last;
                            context.push('/menu/$mId');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6.0,
                                offset: const Offset(0, 3),
                              )
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: ad.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) => Container(color: theme.primaryColor),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    )
                                  ),
                                ),
                                Positioned(
                                  bottom: 16.0,
                                  left: 16.0,
                                  right: 16.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ad.title,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Special Offer • Shahganj.online',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Service Category Grid (8 Services)
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore Local Services',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final item = services[index];
                return GestureDetector(
                  onTap: () => context.push(item['route']),
                  child: Column(
                    children: [
                      Container(
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1.0,
                          )
                        ),
                        child: Icon(
                          item['icon'],
                          color: theme.primaryColor,
                          size: 26.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        item['title'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24.0),

            // Real-Time Dynamic Trending Stores (Firestore-driven)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trending Nearby Stores',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            trendingMerchantsStream.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ShimmerList(itemCount: 3, itemHeight: 80.0),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load stores: $err'),
              ),
              data: (merchants) {
                if (merchants.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No active stores available right now.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: merchants.length,
                  itemBuilder: (context, index) {
                    final merchant = merchants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      elevation: 1.0,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(Icons.store, color: theme.primaryColor),
                        ),
                        title: Text(
                          merchant.businessName,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4.0),
                            Text(
                              merchant.addressFormatted ?? 'Shahganj, UP',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14.0, color: Colors.amber),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${merchant.rating} (${merchant.ratingCount})',
                                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: merchant.isOpen ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    merchant.isOpen ? 'OPEN' : 'CLOSED',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: merchant.isOpen ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/menu/${merchant.uid}'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPromoBanner(ThemeData theme) {
    return Container(
      height: 160.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bolt,
              size: 180.0,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 24.0, right: 24.0, bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPI-First Quick Payments',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Zero Cash Handoffs. E-Rickshaw Ride Sharing at ₹10',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
