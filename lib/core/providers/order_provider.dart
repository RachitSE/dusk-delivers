import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'cart_provider.dart';
import '../constants/menu_data.dart';

class OrderItem {
  final String id;
  final int amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String firestoreId;
  final String userPhone;
  final String branch; // NEW
  final String status; // NEW (Replaces the timer-only logic)

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    required this.userPhone,
    required this.branch,
    this.status = 'Pending',
    this.firestoreId = '',
  });

  // Keep your remainingSeconds logic for the UI progress bars
  int get remainingSeconds {
    final elapsed = DateTime.now().difference(dateTime).inSeconds;
    final remaining = 1200 - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'userPhone': userPhone,
      'branch': branch,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
      'products': products.map((p) => {
        'menuItemId': p.menuItem.id,
        'name': p.menuItem.name,
        'price': p.menuItem.price,
        'quantity': p.quantity,
        'imageUrl': p.menuItem.imageUrl,
      }).toList(),
    };
  }

  static OrderItem fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final productsData = data['products'] as List<dynamic>;

    final products = productsData.map((p) {
      return CartItem(
        menuItem: MenuItem(
          id: p['menuItemId'],
          name: p['name'],
          description: '',
          price: p['price'],
          category: '',
          imageUrl: p['imageUrl'] ?? '',
          calories: 0,
          protein: 0,
        ),
        quantity: p['quantity'],
      );
    }).toList();

    return OrderItem(
      firestoreId: doc.id,
      id: data['id'],
      userPhone: data['userPhone'] ?? '',
      branch: data['branch'] ?? 'Bidholi',
      status: data['status'] ?? 'Pending',
      amount: data['amount'],
      dateTime: DateTime.parse(data['dateTime']),
      products: products,
    );
  }
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = []; // Kept original name
  Timer? _timer;
  StreamSubscription? _orderSubscription;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  List<OrderItem> get orders => _orders; // Kept original name

  // Kept original name, updated logic to use status
  OrderItem? get activeOrder {
    try {
      return _orders.firstWhere((o) => o.status != 'Delivered');
    } catch (e) {
      return null;
    }
  }

  OrderProvider() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Keep the timer for UI countdowns
      if (activeOrder != null) notifyListeners();
    });
  }

  // UPDATED: Added an isAdmin toggle so you can use the same listener
  void startOrderListener(String phone, {bool isAdmin = false}) {
    _orderSubscription?.cancel();

    Query query = _db.collection('orders').orderBy('dateTime', descending: true);

    // If not admin, filter by phone. If admin, get everything.
    if (!isAdmin) {
      query = query.where('userPhone', isEqualTo: phone);
    }

    _orderSubscription = query.snapshots().listen((snapshot) {
      _orders = snapshot.docs.map((doc) => OrderItem.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  // NEW: Acceptance Logic for Kitchen
  Future<void> updateStatus(String docId, String newStatus) async {
    await _db.collection('orders').doc(docId).update({'status': newStatus});
  }

  // UPDATED: Added branch parameter
  Future<void> addOrder(List<CartItem> cartProducts, int total, String phone, String branch) async {
    final newOrder = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: total,
      dateTime: DateTime.now(),
      products: cartProducts,
      userPhone: phone,
      branch: branch,
    );

    await _db.collection('orders').add(newOrder.toMap());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orderSubscription?.cancel();
    super.dispose();
  }
}