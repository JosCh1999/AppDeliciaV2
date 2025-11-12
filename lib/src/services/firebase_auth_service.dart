
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart' as myuser;
import 'package:pasteleria_delicia/src/services/firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<myuser.UserModel?> get user {
    return _auth.authStateChanges().asyncMap((user) => user != null ? _firestoreService.getUser(user.uid) : null);
  }

  Future<myuser.UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        return await _firestoreService.getUser(result.user!.uid);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<myuser.UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        final newUser = myuser.UserModel(uid: result.user!.uid, name: name, email: email);
        await _firestoreService.addUser(newUser);
        return newUser;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
