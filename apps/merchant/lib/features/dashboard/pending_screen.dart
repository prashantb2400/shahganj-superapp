// apps/merchant/lib/features/dashboard/pending_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider);

    // [CRITICAL REAL-TIME REDIRECT]: Listen directly to Firestore approval state
    if (user != null) {
      FirebaseFirestore.instance
          .collection('merchants')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final status = doc.data()!['status'] as String?;
          if (status == 'approved') {
            // Instantly redirect when approved in background
            if (context.mounted) {
              context.go('/');
            }
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1F2937)),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                elevation: 4.0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Loading Vetting Micro-animation indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: CircularProgressIndicator(
                              color: theme.primaryColor,
                              strokeWidth: 4.0,
                            ),
                          ),
                          Icon(
                            Icons.access_time_filled,
                            color: theme.primaryColor,
                            size: 40.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),
                      Text(
                        'Vetting in Progress',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Your business profile is currently undergoing verification by the Shahganj rural digital administrative network.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: Color(0xFFDC2626)),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                'Real-time sync active. Do not close this screen. You will be redirected instantly upon vetting approval.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF991B1B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Support Hotlines spec (Phase 3 requirements)
              Text(
                'Need immediate assistance?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // WhatsApp helpline launcher mock
                    },
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: Text(
                      'WhatsApp Vetting Support',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // success green
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
