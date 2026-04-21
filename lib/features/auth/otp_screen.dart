import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../home/main_screen.dart';
import 'registration_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isButtonEnabled = _otpController.text.length == 6;
    });
  }

  void _verifyOtp() async {
    if (!_isButtonEnabled || _isLoading) return;

    // 1. Mock OTP Check
    if (_otpController.text != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Use 123456.', style: GoogleFonts.urbanist(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fullPhone = '+91${widget.phoneNumber}';

      // 2. Check Firestore (with a 10 second timeout)
      final userExists = await authProvider.checkUserExists(fullPhone).timeout(
        const Duration(seconds: 10),
      );

      if (!mounted) return;

      if (userExists) {
        final success = await authProvider.loginExistingUser(fullPhone);
        if (success && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
          );
        } else {
          throw Exception("Login failed");
        }
      } else {
        // New User -> Registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RegistrationScreen(phoneNumber: widget.phoneNumber)),
        );
      }
    } catch (e) {
      // 3. This stops the loader if anything goes wrong!
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection Error: Check your Firestore Rules or Internet.',
                style: GoogleFonts.urbanist(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      debugPrint("OTP Verification Error: $e");
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Verify',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the 6-digit code sent to +91 ${widget.phoneNumber}',
                    style: GoogleFonts.urbanist(
                      color: Colors.white60,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _otpController.text.length == 6
                            ? AppTheme.primaryGold.withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        onChanged: (val) => _validateInputs(),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.primaryGold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 24.0,
                        ),
                        cursorColor: AppTheme.primaryGold,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _isButtonEnabled
                              ? [BoxShadow(color: AppTheme.primaryGold.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
                              : [],
                          gradient: LinearGradient(
                            colors: _isButtonEnabled
                                ? [const Color(0xFFFFD700), AppTheme.primaryGold]
                                : [const Color(0xFF1A1A1A), const Color(0xFF1A1A1A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled && !_isLoading ? _verifyOtp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                              : Text(
                            'Verify OTP',
                            style: GoogleFonts.urbanist(
                              color: _isButtonEnabled ? Colors.black : Colors.white38,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}