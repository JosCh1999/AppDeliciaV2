
import 'package:pasteleria_delicia/src/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 0) {
      quantity--;
    }
  }

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'productName': product.name,
      'productPrice': product.price,
      'productImageUrl': product.imageUrl,
      'productDescription': product.description,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['productId'],
        name: map['productName'],
        description: map['productDescription'],
        price: map['productPrice'],
        imageUrl: map['productImageUrl'],
      ),
      quantity: map['quantity'] ?? 0,
    );
  }
}
