import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Dusk Admin', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: AppTheme.primaryGold,
              tabs: [
                Tab(text: 'Live Orders'),
                Tab(text: 'Menu Management'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLiveOrders(),
                  _buildMenuEditor(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveOrders() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('dateTime', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index];
            return ListTile(
              title: Text('Order #${order.id.substring(0,5)}', style: const TextStyle(color: Colors.white)),
              subtitle: Text(order['status'], style: const TextStyle(color: AppTheme.primaryGold)),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () => order.reference.update({'status': 'Preparing'}),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuEditor() {
    return Center(
      child: ElevatedButton(
        onPressed: () => _uploadDefaultMenu(),
        child: const Text('Sync Menu to Firestore'),
      ),
    );
  }

  Future<void> _uploadDefaultMenu() async {
    // This function will loop through your local MenuData.items
    // and push them to Firestore 'products' collection.
  }
}