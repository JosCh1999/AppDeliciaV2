
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/order_model.dart';
import 'package:pasteleria_delicia/src/providers/cart_provider.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _ordersCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> placeOrder(String userId, CartProvider cartProvider, ShippingAddress shippingAddress) async {
    final order = OrderModel(
      userId: userId,
      items: cartProvider.items,
      totalAmount: cartProvider.totalAmount,
      shippingAddress: shippingAddress,
      createdAt: Timestamp.now(),
    );

    await _ordersCollection.add(order.toMap());
  }
}
