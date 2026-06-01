// apps/merchant/lib/features/rider/rider_dispatch_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_models/core_models.dart';
import 'package:firebase_sdk/firebase_sdk.dart';

class RiderDispatchOverlay extends StatefulWidget {
  final OrderModel order;
  final String riderId;
  final VoidCallback onDismiss;

  const RiderDispatchOverlay({
    Key? key,
    required this.order,
    required this.riderId,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<RiderDispatchOverlay> createState() => _RiderDispatchOverlayState();
}

class _RiderDispatchOverlayState extends State<RiderDispatchOverlay> {
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // [CRITICAL WAKELOCK]: Section 12 spec keeps mobile screen active on alert
    WakelockPlus.enable();

    // Start 30s countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining -= 1);
      } else {
        _declineDispatch(); // Auto-decline on countdown expiry
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable(); // Release wakelock screen lock
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A).withOpacity(0.95), // Deep Dark Rider background
      body: SafeArea(
        child: Center(
          child: Padding(
            key: const ValueKey('dispatch_card_container'),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
              color: const Color(0xFF1E293B), // Rider dark surface
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    // Priority circular pulse indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: CircularProgressIndicator(
                            value: _secondsRemaining / 30,
                            color: const Color(0xFF10B981), // success neon green
                            strokeWidth: 6.0,
                          ),
                        ),
                        Text(
                          '${_secondsRemaining}s',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 28.0),
                    Text(
                      'INCOMING DISPATCH',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF1F5F9),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'E-Rickshaw Delivery Request Assigned',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24.0),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 16.0),

                    // Destination Info
                    Row(
                      children: [
                        const Icon(Icons.store, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PICKUP FROM', style: TextStyle(fontSize: 10.0, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                              Text(
                                'Shahganj Restaurant Store',
                                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFF43F5E)),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DELIVER TO', style: TextStyle(fontSize: 10.0, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                              Text(
                                widget.order.deliveryAddress.formattedAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 32.0),

                    // Action buttons (Accept/Decline)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _declineDispatch,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: Text(
                              'DECLINE',
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _acceptDispatch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981), // neon green success
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: Text(
                              'ACCEPT',
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Updates order to accepted/preparing state, lock rider status
  Future<void> _acceptDispatch() async {
    _timer?.cancel();
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      batch.update(FirebaseFirestore.instance.collection('orders').doc(widget.order.id), {
        'status': 'preparing',
      });

      batch.update(FirebaseFirestore.instance.collection('riders').doc(widget.riderId), {
        'status': 'busy',
      });

      await batch.commit();
      widget.onDismiss();
    } catch (e) {
      print("❌ Accept dispatch error: $e");
    }
  }

  /// Declines the request, freeing up the rider and returning the order to pool
  Future<void> _declineDispatch() async {
    _timer?.cancel();
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      batch.update(FirebaseFirestore.instance.collection('orders').doc(widget.order.id), {
        'riderId': FieldValue.delete(),
        'status': 'confirmed', // Returns status to confirmed to search another rider
      });

      batch.update(FirebaseFirestore.instance.collection('riders').doc(widget.riderId), {
        'status': 'available',
      });

      await batch.commit();
      widget.onDismiss();
    } catch (e) {
      print("❌ Decline dispatch error: $e");
    }
  }
}
