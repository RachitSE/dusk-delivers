import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/order_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedBranch = "Bidholi"; // Branch Switcher

  @override
  void initState() {
    super.initState();
    // Use the updated listener with isAdmin: true to fetch ALL orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .startOrderListener("", isAdmin: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Use the original 'orders' getter, then filter locally by branch
    final branchOrders = orderProvider.orders.where((o) => o.branch == _selectedBranch).toList();

    // Calculate live sales for this specific branch
    final totalSales = branchOrders.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Kitchen Control",
            style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [ _buildBranchToggle() ],
      ),
      body: Column(
        children: [
          _buildSalesSummary(totalSales),
          Expanded(
            child: branchOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: branchOrders.length,
              itemBuilder: (ctx, i) => _AdminOrderCard(order: branchOrders[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ["Bidholi", "Pondha"].map((b) {
          bool isSel = _selectedBranch == b;
          return GestureDetector(
            onTap: () => setState(() => _selectedBranch = b),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: isSel ? AppTheme.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Text(b,
                  style: GoogleFonts.urbanist(
                      color: isSel ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                  )
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSalesSummary(int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
            colors: [AppTheme.primaryGold, Color(0xFFC5A000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("LIVE SALES - $_selectedBranch",
              style: GoogleFonts.urbanist(
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1
              )
          ),
          const SizedBox(height: 8),
          Text("₹$total",
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontSize: 38,
                  fontWeight: FontWeight.bold
              )
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Text("No orders for $_selectedBranch yet",
            style: GoogleFonts.urbanist(color: Colors.white24))
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderItem order;
  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ORDER #${order.id.substring(order.id.length - 4)}",
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
              _statusChip(order.status),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          ...order.products.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${p.quantity}x ${p.menuItem.name}",
                    style: GoogleFonts.urbanist(color: Colors.white70)),
                Text("₹${p.menuItem.price * p.quantity}",
                    style: GoogleFonts.spaceGrotesk(color: Colors.white70)),
              ],
            ),
          )),
          const SizedBox(height: 20),
          Row(
            children: [
              if (order.status == 'Pending')
                Expanded(child: _actionBtn("Accept", Colors.green,
                        () => provider.updateStatus(order.firestoreId, 'Preparing'))),
              if (order.status == 'Preparing')
                Expanded(child: _actionBtn("Dispatch", AppTheme.accentPurple,
                        () => provider.updateStatus(order.firestoreId, 'Out for Delivery'))),
              if (order.status == 'Out for Delivery')
                Expanded(child: _actionBtn("Delivered", Colors.blue,
                        () => provider.updateStatus(order.firestoreId, 'Delivered'))),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String title, Color col, VoidCallback tap) {
    return ElevatedButton(
      onPressed: tap,
      style: ElevatedButton.styleFrom(
          backgroundColor: col.withOpacity(0.1),
          foregroundColor: col,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Text(status,
          style: GoogleFonts.urbanist(
              color: AppTheme.primaryGold,
              fontSize: 10,
              fontWeight: FontWeight.bold
          )
      ),
    );
  }
}