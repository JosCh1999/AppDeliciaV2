import 'package:flutter/foundation.dart';
import 'package:pasteleria_delicia/src/models/shipping_type_model.dart';

class ShippingProvider with ChangeNotifier {
  ShippingType _shippingType = ShippingType.delivery;

  ShippingType get shippingType => _shippingType;

  double get shippingCost => _shippingType.cost;

  void setShippingType(ShippingType type) {
    if (_shippingType != type) {
      _shippingType = type;
      debugPrint('🚚 [ShippingProvider] Shipping type changed to: ${type.displayName}');
      notifyListeners();
    }
  }

  void reset() {
    _shippingType = ShippingType.delivery;
    notifyListeners();
  }
}
