import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({Key? key}) : super(key: key);

  @override
  _RideBookingScreenState createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  final MapController _mapController = MapController();
  
  // Shahganj Central coordinates (Asia-South1 reference)
  final LatLng _shahganjCenter = const LatLng(26.0592, 82.6865);
  
  String _bookingType = 'whole'; // 'whole' | 'share'
  int _seatCount = 1;
  
  final TextEditingController _pickupController = TextEditingController(text: 'Shahganj Railway Station');
  final TextEditingController _dropController = TextEditingController(text: 'Shahganj Sabzi Mandi');

  double _estimatedDistance = 2.4; // km

  // OSRM routing cost formulas (Section 10 Phase 4 & Section 11 Rules 17)
  double get _estimatedFare {
    if (_bookingType == 'whole') {
      // Whole e-rickshaw: ₹20 base + ₹15/km
      return 20.0 + (15.0 * _estimatedDistance);
    } else {
      // Share seat: ₹10 base + ₹5/km per seat
      return (10.0 + (5.0 * _estimatedDistance)) * _seatCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book E-Rickshaw',
          style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. [ZERO BILLING MAPS TIER]: OpenStreetMap using flutter_map (Section 2 & 11)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _shahganjCenter,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'online.shahganj.customer',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _shahganjCenter,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(Icons.location_on, color: Colors.green, size: 40.0),
                  ),
                  Marker(
                    point: const LatLng(26.0642, 82.6935),
                    width: 40.0,
                    height: 40.0,
                    child: Icon(Icons.two_wheeler, color: theme.primaryColor, size: 36.0),
                  ),
                ],
              ),
            ],
          ),

          // 2. Input routing fields card (Nominatim visual indicators)
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _pickupController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.circle, color: Colors.green, size: 14.0),
                        hintText: 'Enter Pickup Location',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 12.0),
                    TextField(
                      controller: _dropController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.square, color: Colors.red, size: 14.0),
                        hintText: 'Enter Drop Location',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Slide up cost sheet and booking controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16.0,
                    offset: const Offset(0, -4),
                  )
                ]
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Type selection (Whole vs Share)
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Book Entire Rickshaw')),
                            selected: _bookingType == 'whole',
                            onSelected: (val) {
                              setState(() {
                                _bookingType = 'whole';
                              });
                            },
                            selectedColor: theme.primaryColor.withOpacity(0.15),
                            checkmarkColor: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Share Seat (₹10 Base)')),
                            selected: _bookingType == 'share',
                            onSelected: (val) {
                              setState(() {
                                _bookingType = 'share';
                              });
                            },
                            selectedColor: theme.primaryColor.withOpacity(0.15),
                            checkmarkColor: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    if (_bookingType == 'share') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Select Passenger Seats:', style: TextStyle(fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (_seatCount > 1) {
                                    setState(() => _seatCount--);
                                  }
                                },
                              ),
                              Text('$_seatCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  if (_seatCount < 4) {
                                    setState(() => _seatCount++);
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                    ],

                    // Cost estimation details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${_estimatedFare.toStringAsFixed(0)}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Distance: ${_estimatedDistance}km • UPI-first Price',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Searching for e-rickshaws near stations...'),
                                backgroundColor: theme.primaryColor,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Confirm Ride Booking'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
