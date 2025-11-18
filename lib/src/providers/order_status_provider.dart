import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/order_model.dart';
import 'package:pasteleria_delicia/src/services/stock_service.dart';

class OrderStatusProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StockService _stockService = StockService();
  bool _isUpdating = false;

  bool get isUpdating => _isUpdating;

  /// Actualiza el estado de un pedido y maneja el stock
  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    _isUpdating = true;
    notifyListeners();

    try {
      debugPrint('📝 [OrderStatusProvider] Updating order ${order.id} status to: $newStatus');

      // Si el pedido es entregado, descontar el stock
      if (newStatus.toLowerCase() == 'entregado' && order.status.toLowerCase() != 'entregado') {
        debugPrint('🎁 [OrderStatusProvider] Order marked as delivered, decreasing stock...');
        await _stockService.decreaseStockForDeliveredOrder(order);
      }

      // Si el pedido es cancelado desde un estado anterior, restaurar el stock
      if (newStatus.toLowerCase() == 'cancelado' && order.status.toLowerCase() != 'cancelado') {
        if (order.status.toLowerCase() == 'entregado') {
          debugPrint('🔄 [OrderStatusProvider] Order cancelled from delivered state, increasing stock...');
          await _stockService.increaseStockForCancelledOrder(order);
        }
      }

      // Actualizar el estado en Firestore
      await _firestore.collection('orders').doc(order.id).update({
        'status': newStatus,
      });

      debugPrint('✅ [OrderStatusProvider] Order status updated successfully');
    } catch (e) {
      debugPrint('❌ [OrderStatusProvider] Error updating order status: $e');
      throw Exception('Error al actualizar el pedido: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
