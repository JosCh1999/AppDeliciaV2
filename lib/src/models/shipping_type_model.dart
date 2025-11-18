enum ShippingType {
  delivery,
  pickup;

  double get cost {
    switch (this) {
      case ShippingType.delivery:
        return 5.0;
      case ShippingType.pickup:
        return 0.0;
    }
  }

  String get displayName {
    switch (this) {
      case ShippingType.delivery:
        return 'Delivery (S/. 5.00)';
      case ShippingType.pickup:
        return 'Recojo en tienda (Gratis)';
    }
  }
}
