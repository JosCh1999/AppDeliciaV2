import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteleria_delicia/src/models/order_model.dart';

class StockService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance.collection('products');

  /// Descuenta el stock de los productos cuando un pedido es entregado
  Future<void> decreaseStockForDeliveredOrder(OrderModel order) async {
    try {
      debugPrint('📦 [StockService] Decreasing stock for order: ${order.id}');
      
      // Por cada item en el pedido, descontar el stock
      for (final item in order.items) {
        final productId = item.product.id;
        final quantityToDeduct = item.quantity;
        
        debugPrint('   - Deducting $quantityToDeduct units from product: $productId');
        
        // Obtener el documento del producto
        final productDoc = await _productsCollection.doc(productId).get();
        
        if (productDoc.exists) {
          final currentStock = (productDoc['stock'] ?? 0) as int;
          final newStock = (currentStock - quantityToDeduct).clamp(0, double.infinity).toInt();
          
          debugPrint('   - Product $productId: stock $currentStock → $newStock');
          
          // Actualizar el stock en Firestore
          await _productsCollection.doc(productId).update({
            'stock': newStock,
          });
        } else {
          debugPrint('   ⚠️ Product $productId not found in Firestore');
        }
      }
      
      debugPrint('✅ [StockService] Stock decreased successfully for order: ${order.id}');
    } catch (e) {
      debugPrint('❌ [StockService] Error decreasing stock: $e');
      throw Exception('Error al actualizar el stock: $e');
    }
  }

  /// Aumenta el stock si un pedido es cancelado
  Future<void> increaseStockForCancelledOrder(OrderModel order) async {
    try {
      debugPrint('📦 [StockService] Increasing stock for cancelled order: ${order.id}');
      
      for (final item in order.items) {
        final productId = item.product.id;
        final quantityToAdd = item.quantity;
        
        debugPrint('   - Adding $quantityToAdd units to product: $productId');
        
        final productDoc = await _productsCollection.doc(productId).get();
        
        if (productDoc.exists) {
          final currentStock = (productDoc['stock'] ?? 0) as int;
          final newStock = currentStock + quantityToAdd;
          
          debugPrint('   - Product $productId: stock $currentStock → $newStock');
          
          await _productsCollection.doc(productId).update({
            'stock': newStock,
          });
        }
      }
      
      debugPrint('✅ [StockService] Stock increased successfully for cancelled order: ${order.id}');
    } catch (e) {
      debugPrint('❌ [StockService] Error increasing stock: $e');
      throw Exception('Error al restaurar el stock: $e');
    }
  }

  /// Obtiene el stock actual de un producto
  Future<int> getProductStock(String productId) async {
    try {
      final productDoc = await _productsCollection.doc(productId).get();
      if (productDoc.exists) {
        return (productDoc['stock'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      debugPrint('❌ [StockService] Error getting stock: $e');
      return 0;
    }
  }
}
