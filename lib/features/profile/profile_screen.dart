import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/order_provider.dart';
import '../auth/login_screen.dart';
import '../auth/phone_auth_screen.dart';
import '../orders/orders_screen.dart';
import '../location/map_picker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, AuthProvider auth) {
    final controller = TextEditingController(text: auth.currentUser?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('What should we call you?',
            style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name...',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold.withOpacity(0.2))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGold)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                // We use updateAddress logic to update the name field as well
                await auth.updateAddress(auth.currentUser!.address, name: controller.text.trim());
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  void _openMapPicker(BuildContext context, AuthProvider auth) async {
    LatLng initial = LatLng(auth.currentUser?.lat ?? 30.3708, auth.currentUser?.lng ?? 77.9748);
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPickerScreen(initialPosition: initial)));
    if (result != null) {
      final LatLng picked = result['position'];
      await auth.updateAddress(result['address'], lat: picked.latitude, lng: picked.longitude);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        expand: false,
        builder: (_, scroller) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                alignment: Alignment.center, // Changed from 'align' to 'alignment'
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10)
                ),
              ),              const SizedBox(height: 24),
              Text('Privacy Policy', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scroller,
                  children: [
                    _policySection('1. Data Collection', 'We collect your phone number for authentication, your name for order personalization, and your GPS location to ensure accurate late-night delivery to your specific hostel or location.'),
                    _policySection('2. How We Use Data', 'Your information is used solely to process food orders, coordinate with delivery riders, and provide customer support. We do not sell your data to third parties.'),
                    _policySection('3. Geofencing', 'Dusk Delivers uses location data even when the app is closed to provide live order tracking and to verify you are within our service zones (Pondha/Bidholi).'),
                    _policySection('4. Account Deletion', 'You have the right to delete your account at any time. This action will permanently wipe your phone number, order history, and saved addresses from our Firebase servers.'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body, style: GoogleFonts.urbanist(color: Colors.white70, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = auth.currentUser;

    if (user == null) return _buildGuestProfile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  Container(
                    width: 85, height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryGold, width: 2),
                      image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200'), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(user.name, style: GoogleFonts.urbanist(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            IconButton(onPressed: () => _showEditNameDialog(context, auth), icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryGold, size: 28)),
                          ],
                        ),
                        Text(user.phone, style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 14)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('PREMIUM MEMBER', style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  _buildStatCard('Orders', '${orderProvider.orders.length}', Icons.receipt_long_rounded),
                  const SizedBox(width: 12),
                  _buildStatCard('Points', '${user.points}', Icons.stars_rounded),
                  const SizedBox(width: 12),
                  _buildStatCard('Rank', 'Gold', Icons.workspace_premium_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                children: [
                  _buildMenuTile('Order History', Icons.history_rounded, isFirst: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(backgroundColor: Colors.black, body: OrdersScreen())))),
                  _buildMenuTile('Manage Address', Icons.map_outlined, subtitle: user.address, onTap: () => _openMapPicker(context, auth)),
                  _buildMenuTile('Privacy & Security', Icons.security_rounded, onTap: () => _showPrivacyPolicy(context)),
                  _buildMenuTile('Help Center', Icons.support_agent_rounded),
                  _buildMenuTile('Settings', Icons.settings_rounded, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionButton('Log Out', Icons.logout_rounded, Colors.white10, Colors.white, () async {
                    await auth.logout();
                    if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                  }),
                  const SizedBox(height: 16),
                  _buildActionButton('Delete Account', Icons.delete_forever_rounded, Colors.redAccent.withOpacity(0.05), Colors.redAccent, () {
                    _confirmDeleteAccount(context, auth);
                  }, isOutline: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text('Version 1.2.4 • Made for UPES Students', style: GoogleFonts.urbanist(color: Colors.white24, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGold.withOpacity(0.8), size: 22),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.urbanist(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, {String? subtitle, bool isFirst = false, bool isLast = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppTheme.accentPurple, size: 22)),
      title: Text(title, style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.urbanist(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color bg, Color textCol, VoidCallback onTap, {bool isOutline = false}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          side: BorderSide(color: isOutline ? textCol.withOpacity(0.2) : Colors.transparent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textCol, size: 20),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.urbanist(color: textCol, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: AppTheme.primaryGold.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person_add_rounded, size: 60, color: AppTheme.primaryGold)),
            const SizedBox(height: 32),
            Text('Join the Dusk Fam', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Sign in to track your orders, earn reward points, and unlock student discounts.', textAlign: TextAlign.center, style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 16, height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 64,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhoneAuthScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: Text('Login / Sign Up', style: GoogleFonts.urbanist(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Account?', style: GoogleFonts.urbanist(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('This is permanent. You will lose all your points and order history.', style: GoogleFonts.urbanist(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await auth.deleteAccount();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}