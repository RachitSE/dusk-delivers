import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Start listener for this specific user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<OrderProvider>(context, listen: false).startOrderListener(user.phone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Text(
                'My Orders',
                style: GoogleFonts.urbanist(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: user == null
                  ? _buildLoginState()
                  : orderData.orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 120),
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, i) => _OrderCard(order: orderData.orders[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginState() {
    return Center(child: Text("Login to track your food", style: GoogleFonts.urbanist(color: Colors.white54)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food_rounded, color: Colors.white.withOpacity(0.05), size: 100),
          const SizedBox(height: 16),
          Text('No orders yet', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// _OrderCard remains the same as your previous code

class _OrderCard extends StatelessWidget {
  final OrderItem order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                        style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.dateTime.day}/${order.dateTime.month}/${order.dateTime.year} • ${order.dateTime.hour}:${order.dateTime.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                    ),
                    child: Text(
                      order.status,
                      style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white.withOpacity(0.05),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...order.products.map(
                        (prod) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${prod.quantity}x ${prod.menuItem.name}',
                            style: GoogleFonts.urbanist(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            '₹${prod.menuItem.price * prod.quantity}',
                            style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('₹${order.amount}', style: GoogleFonts.spaceGrotesk(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}