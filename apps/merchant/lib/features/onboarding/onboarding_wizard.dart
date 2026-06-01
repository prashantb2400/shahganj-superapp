// apps/merchant/lib/features/onboarding/onboarding_wizard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_models/core_models.dart';
import '../auth/auth_provider.dart';

class OnboardingWizard extends ConsumerStatefulWidget {
  const OnboardingWizard({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard> {
  int _currentStep = 0;
  
  // Step 1: Owner Details
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  
  // Step 2: Category
  String _selectedCategory = 'restaurant';
  
  // Step 3: Business Info
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  
  // Step 4: Documents (Simulated)
  String _documentLicense = 'UP-62-983178239';

  // Step 5: Parameters
  double _minOrder = 100.0;
  double _deliveryFee = 20.0;
  double _deliveryRadius = 5.0;
  double _hourlyRate = 150.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shahganj Business Onboarding',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          )
        ],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          } else {
            _submitOnboarding(user?.uid ?? '');
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 5;
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                    ),
                    child: Text(
                      isLast ? 'SUBMIT FOR VETTING' : 'CONTINUE',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: Text('BACK', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Owner Profile
          Step(
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
            title: Text('Owner Profile', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            content: Column(
              children: [
                TextField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(labelText: 'Owner Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: _ownerPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact Phone Number', border: OutlineInputBorder(), prefixText: '+91 '),
                ),
              ],
            ),
          ),
          // Step 2: Category
          Step(
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
            title: Text('Category of Service', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            content: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'restaurant', child: Text('Restaurant / Food Joint')),
                DropdownMenuItem(value: 'electrician', child: Text('Electrician Services')),
                DropdownMenuItem(value: 'plumber', child: Text('Plumbing Services')),
                DropdownMenuItem(value: 'beauty', child: Text('Beauty & Salon Care')),
                DropdownMenuItem(value: 'hospital', child: Text('OPD Clinic / Pharmacy')),
                DropdownMenuItem(value: 'car_rental', child: Text('Car Rental & E-Rickshaw')),
                DropdownMenuItem(value: 'mart', child: Text('Supermarket / Mart')),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val ?? 'restaurant'),
            ),
          ),
          // Step 3: Business Information
          Step(
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.editing,
            title: Text('Business Details', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            content: Column(
              children: [
                TextField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(labelText: 'Registered Business Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: _businessAddressController,
                  decoration: const InputDecoration(labelText: 'Business Address (Shahganj, UP)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          // Step 4: Documents Simulated
          Step(
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.editing,
            title: Text('Vetting Documents', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            content: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.verified_user, color: Color(0xFF7C3AED)),
                  title: Text('Aadhar & Business License Upload'),
                  subtitle: Text('Compressing uploads automatically into 800x800 WebP formats before saving to preserve bandwidth.'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  initialValue: _documentLicense,
                  decoration: const InputDecoration(labelText: 'Gst / License Registration Number', border: OutlineInputBorder()),
                  onChanged: (val) => _documentLicense = val,
                ),
              ],
            ),
          ),
          // Step 5: Parameters & Settings
          Step(
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.editing,
            title: Text('Operational Parameters', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedCategory == 'restaurant' || _selectedCategory == 'mart') ...[
                  Text('Minimum Delivery Order (₹):', style: theme.textTheme.bodyMedium),
                  Slider(
                    value: _minOrder,
                    min: 50.0,
                    max: 500.0,
                    divisions: 9,
                    label: '₹${_minOrder.round()}',
                    onChanged: (val) => setState(() => _minOrder = val),
                  ),
                  Text('Average Delivery Radius (KM):', style: theme.textTheme.bodyMedium),
                  Slider(
                    value: _deliveryRadius,
                    min: 2.0,
                    max: 15.0,
                    divisions: 13,
                    label: '${_deliveryRadius.round()} KM',
                    onChanged: (val) => setState(() => _deliveryRadius = val),
                  ),
                ] else ...[
                  Text('Hourly Service Consultation Rate (₹):', style: theme.textTheme.bodyMedium),
                  Slider(
                    value: _hourlyRate,
                    min: 50.0,
                    max: 500.0,
                    divisions: 9,
                    label: '₹${_hourlyRate.round()}/hr',
                    onChanged: (val) => setState(() => _hourlyRate = val),
                  ),
                ]
              ],
            ),
          ),
          // Step 6: Vetting Review
          Step(
            isActive: _currentStep >= 5,
            state: _currentStep > 5 ? StepState.complete : StepState.editing,
            title: Text('Vetting Review', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryLine('Owner Name', _ownerNameController.text),
                _buildSummaryLine('Business Name', _businessNameController.text),
                _buildSummaryLine('Address', _businessAddressController.text),
                _buildSummaryLine('Category', _selectedCategory.toUpperCase()),
                _buildSummaryLine('Document No.', _documentLicense),
                const SizedBox(height: 12.0),
                const Text(
                  'By submitting, you agree that your shop details will undergo rural vetting. You will receive active real-time console updates.',
                  style: TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
          Text(value.isEmpty ? 'Not Provided' : value, style: const TextStyle(color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  /// Write onboarding details to Firestore merchants collection
  Future<void> _submitOnboarding(String uid) async {
    if (uid.isEmpty) return;

    try {
      final merchant = MerchantModel(
        uid: uid,
        businessName: _businessNameController.text.isEmpty ? 'Shahganj Brand' : _businessNameController.text,
        ownerName: _ownerNameController.text.isEmpty ? 'Gupta ji' : _ownerNameController.text,
        phone: '+91${_ownerPhoneController.text}',
        email: ref.read(authNotifierProvider)?.email ?? '',
        category: _selectedCategory,
        status: 'pending', // Pending status triggers Pending approval screen
        latitude: 26.0125,
        longitude: 82.6890,
        addressFormatted: _businessAddressController.text.isEmpty 
            ? 'Station Road, Shahganj, UP' 
            : _businessAddressController.text,
        documents: {'license': _documentLicense},
        createdAt: DateTime.now(),
        settings: MerchantSettings(
          minOrder: _minOrder,
          deliveryRadius: _deliveryRadius,
          deliveryFee: _deliveryFee,
          hourlyRate: _hourlyRate,
          deliverySlots: ["10:00 AM - 08:00 PM"],
          availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
        ),
      );

      // Save to merchants collection
      await FirebaseFirestore.instance.collection('merchants').doc(uid).set(merchant.toJson());
      
      // Update local profile role to merchant
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': 'merchant'});

      // Hot reload routing
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Onboarding failed: $e')));
    }
  }
}
