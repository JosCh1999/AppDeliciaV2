
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/cart_item_model.dart';
import 'package:pasteleria_delicia/src/models/product_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _getCartCollection(String userId) {
    return _db.collection('users').doc(userId).collection('cart');
  }

  Stream<List<CartItem>> getCartItems(String userId) {
    return _getCartCollection(userId).snapshots().asyncMap((snapshot) async {
      final cartItems = <CartItem>[];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final productId = data['productId'];

        // Fetch the full product details
        final productDoc = await _db.collection('products').doc(productId).get();
        if (productDoc.exists) {
          final product = Product.fromMap(productDoc.data() as Map<String, dynamic>, productDoc.id);
          cartItems.add(CartItem(product: product, quantity: data['quantity'] ?? 1));
        } else {
          // Handle case where product might have been deleted but is still in cart
          // For now, we'll just skip it
          print('Product with ID $productId not found.');
        }
      }
      return cartItems;
    });
  }

  Future<void> addToCart(String userId, Product product) async {
    final cartCollection = _getCartCollection(userId);
    final existingDoc = await cartCollection.doc(product.id).get();

    if (existingDoc.exists) {
      // If item already exists, increment quantity
      await cartCollection.doc(product.id).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // If item doesn't exist, create a new cart item
      final newCartItem = CartItem(product: product);
      await cartCollection.doc(product.id).set(newCartItem.toMap());
    }
  }

  Future<void> updateQuantity(String userId, String productId, int quantity) async {
    if (quantity <= 0) {
      // Remove item if quantity is zero or less
      await removeFromCart(userId, productId);
    } else {
      await _getCartCollection(userId).doc(productId).update({'quantity': quantity});
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    await _getCartCollection(userId).doc(productId).delete();
  }

  Future<void> clearCart(String userId) async {
    final cartSnapshot = await _getCartCollection(userId).get();
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
