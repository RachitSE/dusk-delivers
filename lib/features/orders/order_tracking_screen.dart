import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/order_provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);

    final order = orderData.orders.firstWhere(
          (o) => o.id == orderId,
      orElse: () => orderData.orders.first,
    );

    int m = order.remainingSeconds ~/ 60;
    int s = order.remainingSeconds % 60;
    String formattedTime = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
              ),
              child: const Center(
                child: Icon(Icons.map_rounded, color: Colors.white24, size: 80),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5)),
                boxShadow: const [
                  BoxShadow(color: Colors.black, blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Details',
                        style: GoogleFonts.urbanist(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.remainingSeconds > 0 ? formattedTime : 'Arrived',
                          style: GoogleFonts.spaceGrotesk(color: AppTheme.primaryGold, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildTimelineItem('Order Received', 'Your order is sent to the kitchen.', Icons.receipt_long_rounded, true, false),
                        _buildTimelineItem('Cooking', 'Preparing your late-night cravings.', Icons.soup_kitchen_rounded, order.remainingSeconds < 1200, order.remainingSeconds >= 600 && order.remainingSeconds > 0),
                        if (order.remainingSeconds < 600 && order.remainingSeconds > 0) _buildRiderInfo(),
                        _buildTimelineItem('On the Way', 'Rider is assigned and heading to you.', Icons.electric_bike_rounded, order.remainingSeconds < 600, order.remainingSeconds < 600 && order.remainingSeconds > 0),
                        _buildTimelineItem('Delivered', 'Enjoy your meal.', Icons.location_on_rounded, order.remainingSeconds == 0, order.remainingSeconds == 0, isLast: true),
                      ],
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

  Widget _buildTimelineItem(String title, String subtitle, IconData icon, bool isCompleted, bool isActive, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryGold : (isCompleted ? AppTheme.primaryGold.withOpacity(0.15) : Colors.white.withOpacity(0.05)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.black : (isCompleted ? AppTheme.primaryGold : Colors.white38),
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppTheme.primaryGold.withOpacity(0.4) : Colors.white.withOpacity(0.05),
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(color: isCompleted || isActive ? Colors.white : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.urbanist(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiderInfo() {
    return Container(
      margin: const EdgeInsets.only(left: 56, bottom: 20, right: 10, top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=100'),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rahul Sharma', style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('UK07 AB 1234', style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.call, color: Colors.greenAccent, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}