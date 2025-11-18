
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
      status: 'Pendiente', // Estado por defecto al crear
    );

    await _ordersCollection.add(order.toMap());
  }

  // Devuelve un stream de pedidos para un usuario específico
  Stream<List<OrderModel>> getOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      } catch (e) {
        print('Error al mapear los pedidos: $e');
        return [];
      }
    });
  }
}
