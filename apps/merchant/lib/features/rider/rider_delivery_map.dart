// apps/merchant/lib/features/rider/rider_delivery_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderDeliveryMap extends StatelessWidget {
  final double riderLat;
  final double riderLng;
  final double destLat;
  final double destLng;
  final String destinationAddress;

  const RiderDeliveryMap({
    Key? key,
    required this.riderLat,
    required this.riderLng,
    required this.destLat,
    required this.destLng,
    required this.destinationAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng riderLocation = LatLng(riderLat, riderLng);
    final LatLng destLocation = LatLng(destLat, destLng);

    // Midpoint calculation to center map view beautifully
    final LatLng centerPoint = LatLng(
      (riderLat + destLat) / 2,
      (riderLng + destLng) / 2,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            // [CRITICAL MAP LAYER]: OpenStreetMap + flutter_map tiles (No Google Maps API Cost spec)
            FlutterMap(
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: 14.0,
                maxZoom: 18.0,
                minZoom: 10.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                
                // Draw route line between rider and destination
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [riderLocation, destLocation],
                      strokeWidth: 4.5,
                      color: const Color(0xFF10B981), // success neon green route path
                    ),
                  ],
                ),

                // Markers overlay
                MarkerLayer(
                  markers: [
                    // Rider E-rickshaw marker
                    Marker(
                      point: riderLocation,
                      width: 40.0,
                      height: 40.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.white, size: 22.0),
                      ),
                    ),
                    // Customer Destination marker
                    Marker(
                      point: destLocation,
                      width: 40.0,
                      height: 40.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 22.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top float panel showing navigation instructions
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation, color: Color(0xFF10B981)),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Navigation Active — Head towards Destination',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              destinationAddress,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
