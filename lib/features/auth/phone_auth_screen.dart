import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      _isButtonEnabled = value.length == 10;
    });
  }

  void _sendOtp() {
    if (_isButtonEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phoneNumber: _phoneController.text),
        ),
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
                color: AppTheme.accentPurple.withOpacity(0.25),
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
                    'Let\'s start',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your phone number to log in or create an account with Dusk.',
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
                        color: _isButtonEnabled
                            ? AppTheme.primaryGold.withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: _isButtonEnabled
                          ? [BoxShadow(color: AppTheme.primaryGold.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          '🇮🇳 +91',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1.5,
                          height: 24,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            onChanged: _validateInput,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            cursorColor: AppTheme.primaryGold,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '0000000000',
                              hintStyle: GoogleFonts.spaceGrotesk(
                                color: Colors.white24,
                                fontSize: 20,
                                letterSpacing: 2.0,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
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
                          onPressed: _isButtonEnabled ? _sendOtp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Send OTP',
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