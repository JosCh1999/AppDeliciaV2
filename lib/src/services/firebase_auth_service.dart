
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart' as myuser;
import 'package:pasteleria_delicia/src/services/firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Stream que notifica en tiempo real si hay un usuario logueado o no
  Stream<myuser.UserModel?> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      // Si hay un usuario, busca sus datos completos en Firestore
      return await _firestoreService.getUser(firebaseUser.uid);
    });
  }

  // Iniciar sesión con email y contraseña
  Future<myuser.UserModel?> signInWithEmailAndPassword(String email, String password) async {
    // El `try-catch` ahora está en el AuthProvider para manejar errores específicos de UI
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (result.user != null) {
      return await _firestoreService.getUser(result.user!.uid);
    }
    return null;
  }

  // --- MÉTODO ACTUALIZADO ---
  // Registrar un nuevo usuario con su información completa
  Future<myuser.UserModel?> registerWithEmailAndPassword(
    myuser.UserModel userToRegister, // Recibe el objeto UserModel
    String password, // Recibe la contraseña
  ) async {
    // 1. Crea el usuario en el servicio de Autenticación de Firebase
    final result = await _auth.createUserWithEmailAndPassword(
      email: userToRegister.email, // Usa el email del objeto
      password: password,
    );

    if (result.user != null) {
      // 2. Si se crea con éxito, obtiene el UID asignado por Firebase
      final uid = result.user!.uid;

      // 3. Crea una instancia final del usuario, ahora con el UID correcto
      final newUser = myuser.UserModel(
        uid: uid,
        name: userToRegister.name,
        email: userToRegister.email,
        phoneNumber: userToRegister.phoneNumber,
        shippingAddress: userToRegister.shippingAddress,
        // Se pueden añadir otros valores por defecto si es necesario
        role: 'cliente',
        profileImageUrl: null,
      );

      // 4. Guarda el objeto de usuario completo en la base de datos Firestore
      await _firestoreService.addUser(newUser);

      // 5. Devuelve el nuevo usuario completamente formado
      return newUser;
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
