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
  final String userPhone; // NEW: To link order to user

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    required this.userPhone,
    this.firestoreId = '',
  });

  int get remainingSeconds {
    final elapsed = DateTime.now().difference(dateTime).inSeconds;
    final remaining = 1200 - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  String get status {
    final rem = remainingSeconds;
    if (rem == 0) return 'Delivered';
    if (rem < 600) return 'On the Way';
    return 'Cooking';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'userPhone': userPhone, // SECURE: Saves who ordered this
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
          imageUrl: p['imageUrl'],
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
      amount: data['amount'],
      dateTime: DateTime.parse(data['dateTime']),
      products: products,
    );
  }
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  Timer? _timer;
  StreamSubscription? _orderSubscription;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  List<OrderItem> get orders => _orders;

  OrderItem? get activeOrder {
    try {
      return _orders.firstWhere((o) => o.remainingSeconds > 0);
    } catch (e) {
      return null;
    }
  }

  OrderProvider() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (activeOrder != null) notifyListeners();
    });
  }

  // NEW: Call this when user logs in to start a private listener
  void startOrderListener(String phone) {
    _orderSubscription?.cancel();
    _orderSubscription = _db.collection('orders')
        .where('userPhone', isEqualTo: phone) // PRIVACY FIX: Only my orders
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      _orders = snapshot.docs.map((doc) => OrderItem.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> addOrder(List<CartItem> cartProducts, int total, String phone) async {
    final newOrder = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: total,
      dateTime: DateTime.now(),
      products: cartProducts,
      userPhone: phone,
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