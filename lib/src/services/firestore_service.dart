
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel> getUser(String uid) {
    return _db.collection('users').doc(uid).get().then((doc) => UserModel.fromDocument(doc));
  }
}
