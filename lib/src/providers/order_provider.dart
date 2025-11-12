
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _userId;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  void updateUser(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (_userId != null) {
        fetchOrders();
      } else {
        _orders = [];
        notifyListeners();
      }
    }
  }

  Future<void> fetchOrders() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      // Consider setting an error state to show in the UI
    }

    _isLoading = false;
    notifyListeners();
  }
}
