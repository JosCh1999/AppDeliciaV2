import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/order_model.dart';
import 'package:pasteleria_delicia/src/services/stock_service.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StockService _stockService = StockService();
  List<OrderModel> _orders = [];
  List<OrderModel> _previousOrders = [];
  bool _isLoading = false;
  String? _currentUserId;
  StreamSubscription? _ordersSubscription;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  // **MÉTODO ACTUALIZADO: Usa un stream listener en lugar de una consulta única**
  Future<void> fetchOrdersForUser(String userId, {bool forceRefresh = false}) async {
    // Si ya estamos escuchando este usuario, no hacer nada (a menos que sea forceRefresh)
    if (!forceRefresh && userId == _currentUserId && _ordersSubscription != null) {
      debugPrint('🔄 [OrderProvider] Already listening to userId: $userId');
      return;
    }

    // Cancelar el listener anterior si existe
    _ordersSubscription?.cancel();

    _isLoading = true;
    _currentUserId = userId;
    _orders = [];
    _previousOrders = [];
    notifyListeners();

    try {
      debugPrint('🔍 [OrderProvider] Setting up real-time listener for userId: $userId');
      
      // Configurar un stream listener que escucha cambios en tiempo real
      _ordersSubscription = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              debugPrint('✅ [OrderProvider] Real-time update: Found ${snapshot.docs.length} orders for user $userId');
              
              // Convertir documentos a modelos
              final newOrders = snapshot.docs.map((doc) => 
                OrderModel.fromMap(doc.data(), doc.id)
              ).toList();
              
              // Mostrar detalles de cada orden encontrada
              for (var i = 0; i < newOrders.length; i++) {
                final order = newOrders[i];
                debugPrint('   Order $i: ID=${order.id}, status=${order.status}, total=${order.totalAmount}');
                
                // Detectar cambios de estado para descontar stock
                _checkAndHandleStatusChange(order);
              }
              
              _previousOrders = _orders;
              _orders = newOrders;
              _isLoading = false;
              notifyListeners();
            },
            onError: (e) {
              debugPrint('❌ [OrderProvider] Error in real-time listener: $e');
              _isLoading = false;
              _orders = [];
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('❌ [OrderProvider] Error setting up listener: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Detecta si un pedido cambió de estado y ejecuta las acciones necesarias
  void _checkAndHandleStatusChange(OrderModel currentOrder) {
    // Buscar la orden anterior con el mismo ID
    try {
      final previousOrderIndex = _previousOrders.indexWhere(
        (order) => order.id == currentOrder.id,
      );
      
      if (previousOrderIndex != -1) {
        final previousOrder = _previousOrders[previousOrderIndex];
        final oldStatus = previousOrder.status.toLowerCase();
        final newStatus = currentOrder.status.toLowerCase();
        
        // Si cambió a "entregado" y no estaba entregado antes, descontar stock
        if (newStatus == 'entregado' && oldStatus != 'entregado') {
          debugPrint('🎁 [OrderProvider] Order ${currentOrder.id} marked as delivered, decreasing stock...');
          _stockService.decreaseStockForDeliveredOrder(currentOrder);
        }
        
        // Si cambió a "cancelado" desde "entregado", restaurar stock
        if (newStatus == 'cancelado' && oldStatus == 'entregado') {
          debugPrint('🔄 [OrderProvider] Order ${currentOrder.id} cancelled from delivered, restoring stock...');
          _stockService.increaseStockForCancelledOrder(currentOrder);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [OrderProvider] Error checking status change: $e');
    }
  }

  void clearOrders() {
    _ordersSubscription?.cancel();
    _orders = [];
    _currentUserId = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      final newOrderWithId = order.copyWith(id: docRef.id);
      _orders.insert(0, newOrderWithId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al añadir el pedido: $e');
      throw Exception('No se pudo registrar el pedido.');
    }
  }
}