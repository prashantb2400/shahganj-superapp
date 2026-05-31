import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // List of 8 core local services outlined in Section 10
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.restaurant, 'title': 'Food Delivery', 'route': '/menu/restaurant_demo'},
      {'icon': Icons.electric_bolt, 'title': 'Electrician', 'route': '/menu/electrician_demo'},
      {'icon': Icons.plumbing, 'title': 'Plumber', 'route': '/menu/plumber_demo'},
      {'icon': Icons.face_retouching_natural, 'title': 'Beauty Care', 'route': '/menu/beauty_demo'},
      {'icon': Icons.local_hospital, 'title': 'OPD Clinic', 'route': '/menu/hospital_demo'},
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
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
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
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promos Carousel Placeholder
            Container(
              height: 160.0,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  )
                ]
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
                    padding: const EdgeInsets.all(24.0),
                    padding: const EdgeInsets.only(top: 32.0, left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPI-First Quick Payments',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
            ),

            // Service Category Grid (8 Services)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore Local Services',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 20.0,
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

            const SizedBox(height: 32.0),

            // Shimmer List Demo instead of centered loading spinning (Section 11 Rules 15)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trending Nearby Stores',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 20.0,
                ),
              ),
            ),
            
            const ShimmerList(itemCount: 3, itemHeight: 70.0),
          ],
        ),
      ),
    );
  }
}
