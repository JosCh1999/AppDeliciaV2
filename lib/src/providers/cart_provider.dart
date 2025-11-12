
import 'package:flutter/material.dart';
import 'package:pasteleria_delicia/src/models/cart_item_model.dart';
import 'package:pasteleria_delicia/src/models/product_model.dart';
import 'package:pasteleria_delicia/src/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _userId;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  void updateUser(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _items = []; // Clear local/previous cart on user change
      if (_userId != null) {
        _listenToCartChanges();
      } else {
        notifyListeners();
      }
    }
  }

  void _listenToCartChanges() {
    _isLoading = true;
    notifyListeners();
    _cartService.getCartItems(_userId!).listen((items) {
      _items = items;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      print("Error listening to cart changes: $error");
      notifyListeners();
    });
  }

  Future<void> addToCart(Product product) async {
    if (_userId != null) {
      // Logged-in user: use Firestore
      try {
        await _cartService.addToCart(_userId!, product);
        // Listener will auto-update
      } catch (e) {
        print('Error adding to cart: $e');
      }
    } else {
      // Guest user: handle locally
      final index = _items.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _items[index].quantity++;
      } else {
        _items.add(CartItem(product: product, quantity: 1));
      }
      notifyListeners(); // Notify UI of local change
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId != null) {
      // Logged-in user
      if (quantity > 0) {
        await _cartService.updateQuantity(_userId!, productId, quantity);
      } else {
        await _cartService.removeFromCart(_userId!, productId);
      }
    } else {
      // Guest user
      final index = _items.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        if (quantity > 0) {
          _items[index].quantity = quantity;
        } else {
          _items.removeAt(index);
        }
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    await updateQuantity(productId, 0);
  }

  Future<void> clearCart() async {
    if (_userId != null) {
      // Logged-in user
      await _cartService.clearCart(_userId!);
    } else {
      // Guest user
      _items = [];
      notifyListeners();
    }
  }
}
