
import 'package:cloud_firestore/cloud_firestore.dart';

// Un modelo para el mapa de la dirección de envío
class ShippingAddress {
  final String address;
  final String city;
  final String postalCode;

  ShippingAddress({
    required this.address,
    required this.city,
    required this.postalCode,
  });

  // Convierte un mapa de Firestore a un objeto ShippingAddress
  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
    );
  }

  // Convierte un objeto ShippingAddress a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'city': city,
      'postalCode': postalCode,
    };
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? profileImageUrl;
  final String? phoneNumber;
  final ShippingAddress? shippingAddress; // Usamos el nuevo modelo

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'cliente',
    this.profileImageUrl,
    this.phoneNumber,
    this.shippingAddress,
  });

  // Se actualiza para leer el mapa de la dirección
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'cliente',
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      // Si el campo existe en Firestore, lo convierte a nuestro objeto
      shippingAddress: data['shippingAddress'] != null
          ? ShippingAddress.fromMap(data['shippingAddress'])
          : null,
    );
  }

  // Se actualiza para escribir el mapa de la dirección
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      // Si la dirección existe, la convierte a un mapa
      'shippingAddress': shippingAddress?.toMap(),
    };
  }
}
