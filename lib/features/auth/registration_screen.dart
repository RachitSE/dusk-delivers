import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../home/main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  const RegistrationScreen({super.key, required this.phoneNumber});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty &&
          _addressController.text.trim().isNotEmpty;
    });
  }

  void _completeRegistration() async {
    if (!_isButtonEnabled) return;

    setState(() => _isLoading = true);

    double lat = 30.3708; // Default Pondha Lat
    double lng = 77.9748; // Default Pondha Lng

    try {
      // Fetch location silently to tag the new user's region
      Position pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 5));
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (e) {
      debugPrint("Location fetch failed, using defaults: $e");
    }

    final success = await Provider.of<AuthProvider>(context, listen: false).registerNewUser(
      '+91${widget.phoneNumber}',
      _nameController.text.trim(),
      _addressController.text.trim(),
      lat,
      lng,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please check your internet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accentPurple.withOpacity(0.15)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text('Almost there', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Text('Just a few details to get your late-night cravings delivered.', style: GoogleFonts.urbanist(color: Colors.white60, fontSize: 16, height: 1.5)),
                  const SizedBox(height: 50),
                  _buildInput(controller: _nameController, hint: 'Full Name', icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildInput(controller: _addressController, hint: 'Hostel / Delivery Address', icon: Icons.location_on_outlined),
                  const Spacer(),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: controller.text.isNotEmpty ? AppTheme.primaryGold.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(icon, color: AppTheme.primaryGold),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => _validateInputs(),
              style: GoogleFonts.urbanist(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.urbanist(color: Colors.white24), border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60, width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: _isButtonEnabled ? [const Color(0xFFFFD700), AppTheme.primaryGold] : [const Color(0xFF1A1A1A), const Color(0xFF1A1A1A)]),
        ),
        child: ElevatedButton(
          onPressed: _isButtonEnabled && !_isLoading ? _completeRegistration : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : Text('Complete Setup', style: GoogleFonts.urbanist(color: _isButtonEnabled ? Colors.black : Colors.white38, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}