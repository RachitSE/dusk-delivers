import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String phone;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int points;

  UserModel({
    required this.phone,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.points,
  });
}

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    loadLocalUser();
  }

  Future<void> loadLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('userPhone');

      if (phone != null) {
        final doc = await _db.collection('users').doc(phone).get();
        if (doc.exists) {
          _currentUser = UserModel(
            phone: doc.id,
            name: doc['name'] ?? 'User',
            address: doc['address'] ?? 'Add Delivery Address',
            lat: (doc['lat'] ?? 30.3708).toDouble(),
            lng: (doc['lng'] ?? 77.9748).toDouble(),
            points: doc['points'] ?? 0,
          );
          notifyListeners();
        } else {
          await logout();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> checkUserExists(String phone) async {
    try {
      final doc = await _db.collection('users').doc(phone).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginExistingUser(String phone) async {
    try {
      final doc = await _db.collection('users').doc(phone).get();
      if (doc.exists) {
        _currentUser = UserModel(
          phone: doc.id,
          name: doc['name'] ?? 'User',
          address: doc['address'] ?? 'Add Delivery Address',
          lat: (doc['lat'] ?? 30.3708).toDouble(),
          lng: (doc['lng'] ?? 77.9748).toDouble(),
          points: doc['points'] ?? 50,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPhone', phone);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerNewUser(String phone, String name, String address, double lat, double lng) async {
    try {
      final docRef = _db.collection('users').doc(phone);

      await docRef.set({
        'name': name,
        'phone': phone,
        'address': address,
        'lat': lat,
        'lng': lng,
        'points': 50,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _currentUser = UserModel(
        phone: phone,
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        points: 50,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPhone', phone);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateAddress(String newAddress, {double? lat, double? lng, String? name}) async {
    if (_currentUser == null) return;

    final Map<String, dynamic> updateData = {
      'address': newAddress,
      'name': name ?? _currentUser!.name, // Keeps old name if new one isn't provided
    };

    if (lat != null) updateData['lat'] = lat;
    if (lng != null) updateData['lng'] = lng;

    // Push to Firestore
    await _db.collection('users').doc(_currentUser!.phone).update(updateData);

    // Update local UI state
    _currentUser = UserModel(
      phone: _currentUser!.phone,
      name: name ?? _currentUser!.name,
      address: newAddress,
      lat: lat ?? _currentUser!.lat,
      lng: lng ?? _currentUser!.lng,
      points: _currentUser!.points,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_currentUser != null) {
      await _db.collection('users').doc(_currentUser!.phone).delete();
      await logout();
    }
  }
}