
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/cart_item_model.dart';

class OrderModel {
  final String? id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final ShippingAddress shippingAddress;
  final String status;
  final Timestamp createdAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    this.status = 'Pendiente',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress.toMap(),
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      shippingAddress: ShippingAddress.fromMap(map['shippingAddress'] as Map<String, dynamic>),
      status: map['status'] ?? 'Pendiente',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}

class ShippingAddress {
  final String name;
  final String address;
  final String city;
  final String postalCode;

  ShippingAddress({
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'postalCode': postalCode,
    };
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
    );
  }
}
