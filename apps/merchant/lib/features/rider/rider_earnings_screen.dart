// apps/merchant/lib/features/rider/rider_earnings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:core_models/core_models.dart';
import '../auth/auth_provider.dart';

class RiderEarningsScreen extends ConsumerWidget {
  const RiderEarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rider = ref.watch(activeRiderProvider);

    if (rider == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          'Earnings & Statistics',
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Total Earnings Meter (Glow Card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    blurRadius: 16.0,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL REVENUE',
                    style: TextStyle(color: Color(0xFFA7F3D0), fontWeight: FontWeight.bold, fontSize: 11.0, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    '₹${rider.earnings.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 42.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFFA7F3D0), size: 16.0),
                      const SizedBox(width: 6.0),
                      Text(
                        'Direct transfers enabled to PayTM/UPI',
                        style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFA7F3D0)),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24.0),

            // 2. Dual Stats grid (Deliveries & Ratings)
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_shipping, color: Color(0xFF38BDF8), size: 28.0),
                          const SizedBox(height: 12.0),
                          Text(
                            '${rider.totalDeliveries}',
                            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          const Text('Completed Drop-offs', style: TextStyle(color: Color(0xFF64748B), fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFBBF24), size: 28.0),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              Text(
                                '${rider.rating}',
                                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4.0),
                              const Icon(Icons.star, color: Color(0xFFFBBF24), size: 16.0),
                            ],
                          ),
                          const Text('Average Review', style: TextStyle(color: Color(0xFF64748B), fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28.0),

            // 3. Android Battery Optimization sheet card (Rule 21 spec)
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: const BorderSide(color: Color(0xFF334155), width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.battery_alert, color: Color(0xFFFBBF24), size: 36.0),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ignore Battery Optimizations',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'Required on Redmi/budget phones to keep background location streams awake.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.0),
                          ),
                          const SizedBox(height: 12.0),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF10B981),
                                  content: Text('Directing to Android settings. Please check "No Restrictions" for Shahganj App.'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            ),
                            child: const Text('ALLOW BACKGROUND SYNC', style: TextStyle(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32.0),
            
            // 4. Recent completed runs list
            Text(
              'RECENT COMPLETED RUNS',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16.0),

            _buildDeliveryItem('Guptha Foods', 'Rohan Kumar', '₹45.00', '10 mins ago'),
            _buildDeliveryItem('Shahganj Mart', 'Shalini Verma', '₹35.00', '1 hour ago'),
            _buildDeliveryItem('Gupta Restaurant', 'Anil Gupta', '₹60.00', 'Yesterday'),

          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryItem(String merchant, String customer, String payout, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: const Color(0xFF1E293B),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Color(0xFF10B981)),
        ),
        title: Text(
          merchant,
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Customer: $customer • $time',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.0),
        ),
        trailing: Text(
          payout,
          style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
      ),
    );
  }
}
