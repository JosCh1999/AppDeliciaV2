import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _productCollection = FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // This method uses the product's own ID as the document ID in Firestore.
  Future<void> addProductWithId(Product product) {
    return _productCollection.doc(product.id).set(product.toMap());
  }

  // This method is to add products for the first time
  Future<void> addSampleProducts() async {
    final products = [
      Product(
        id: '1',
        name: 'Pastel de Chocolate',
        description: 'Delicioso pastel de chocolate con cobertura de ganache.',
        price: 25.00,
        imageUrl: 'https://images.pexels.com/photos/2067396/pexels-photo-2067396.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      ),
      Product(
        id: '2',
        name: 'Pastel de Fresa',
        description: 'Pastel de fresa con crema batida y fresas frescas.',
        price: 22.00,
        imageUrl: 'https://images.pexels.com/photos/140831/pexels-photo-140831.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      ),
      Product(
        id: '3',
        name: 'Cheesecake de Frambuesa',
        description: 'Cremoso cheesecake con una capa de mermelada de frambuesa.',
        price: 28.00,
        imageUrl: 'https://images.pexels.com/photos/3026804/pexels-photo-3026804.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      ),
      Product(
        id: '4',
        name: 'Tarta de Manzana',
        description: 'Tarta de manzana casera con canela y una base crujiente.',
        price: 20.00,
        imageUrl: 'https://images.pexels.com/photos/2373520/pexels-photo-2373520.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      ),
      Product(
        id: '5',
        name: 'Galletas con Chips de Chocolate',
        description: 'Docena de galletas recién horneadas con chips de chocolate.',
        price: 12.00,
        imageUrl: 'https://images.pexels.com/photos/2067405/pexels-photo-2067405.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      ),
    ];

    // Use a batch write for efficiency
    final batch = _db.batch();
    for (var product in products) {
      final docRef = _productCollection.doc(product.id);
      batch.set(docRef, product.toMap());
    }
    await batch.commit();
  }
}
