import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Added for branch detection
import '../../core/theme/theme.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/routing_service.dart'; // Added for branch detection
import '../orders/order_tracking_screen.dart';
import '../auth/phone_auth_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showLoginRequiredSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF101010),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_accounts_rounded, color: AppTheme.primaryGold, size: 60),
                  const SizedBox(height: 16),
                  Text('Login Required', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Please log in or sign up to place your order and track your delivery.', textAlign: TextAlign.center, style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 32),
                  SizedBox(
                      width: double.infinity, height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PhoneAuthScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: Text('Login / Sign Up', style: GoogleFonts.urbanist(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                  )
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 480),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Your Cart',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${cart.itemCount} Items',
                      style: GoogleFonts.urbanist(
                        color: AppTheme.primaryGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...List.generate(cart.items.length, (index) {
                final cartItem = cart.items.values.toList()[index];
                final productId = cart.items.keys.toList()[index];
                return _CartItemTile(cartItem: cartItem, productId: productId);
              }),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCheckoutSection(context, cart),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.15),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A0A0A),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppTheme.primaryGold,
                  size: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Your cart is empty',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore the menu and add some\nlate-night cravings.',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              color: Colors.white54,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cart) {
    final subtotal = cart.totalAmount;
    final taxes = (subtotal * 0.05).round();
    const delivery = 30;
    final total = subtotal + taxes + delivery;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 110),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: AppTheme.primaryGold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
                        cursorColor: AppTheme.primaryGold,
                        decoration: InputDecoration(
                          hintText: 'Promo Code',
                          hintStyle: GoogleFonts.urbanist(color: Colors.white38, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.urbanist(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildReceiptRow('Subtotal', '₹$subtotal', isTotal: false),
              const SizedBox(height: 12),
              _buildReceiptRow('Taxes & Fees', '₹$taxes', isTotal: false),
              const SizedBox(height: 12),
              _buildReceiptRow('Delivery', '₹$delivery', isTotal: false),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: CustomPaint(
                  painter: _DashedLinePainter(),
                  child: const SizedBox(height: 1, width: double.infinity),
                ),
              ),
              _buildReceiptRow('Total', '₹$total', isTotal: true),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), AppTheme.primaryGold],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (cart.items.isEmpty) return;

                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      if (!auth.isAuthenticated) {
                        _showLoginRequiredSheet(context);
                        return;
                      }

                      // 1. Get current branch using user's saved location
                      final StoreBranch currentBranch = StoreRoutingService.getFulfillmentBranch(
                          Position(
                            latitude: auth.currentUser!.lat ?? 30.3708,
                            longitude: auth.currentUser!.lng ?? 77.9748,
                            timestamp: DateTime.now(), accuracy: 0, altitude: 0,
                            heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
                          )
                      );

                      // Convert enum to string: "Bidholi" or "Pondha"
                      final String branchName = currentBranch == StoreBranch.bidholi ? "Bidholi" : "Pondha";

                      final userPhone = auth.currentUser!.phone;

                      // 2. Create local object for navigation
                      final newOrder = OrderItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        amount: total,
                        dateTime: DateTime.now(),
                        products: cart.items.values.toList(),
                        userPhone: userPhone,
                        branch: branchName, // Passed branch
                      );

                      // 3. Call addOrder with the branch name
                      await Provider.of<OrderProvider>(context, listen: false).addOrder(
                        cart.items.values.toList(),
                        total,
                        userPhone,
                        branchName, // Passed branch
                      );

                      cart.clear();

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(orderId: newOrder.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Place Order',
                      style: GoogleFonts.urbanist(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String amount, {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            color: isTotal ? Colors.white : Colors.white60,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.spaceGrotesk(
            color: isTotal ? AppTheme.primaryGold : Colors.white,
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final String productId;

  const _CartItemTile({required this.cartItem, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: ValueKey(productId),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => Provider.of<CartProvider>(context, listen: false).removeItem(productId),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Row(
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: DecorationImage(
                    image: NetworkImage(cartItem.menuItem.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.menuItem.name,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${cartItem.menuItem.price}',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.primaryGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Provider.of<CartProvider>(context, listen: false).decrementItem(productId),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const Icon(Icons.remove_rounded, color: Colors.white70, size: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${cartItem.quantity}',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Provider.of<CartProvider>(context, listen: false).addItem(cartItem.menuItem),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGold,
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.black, size: 14),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 6, startX = 0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}