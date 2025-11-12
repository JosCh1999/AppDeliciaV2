
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart' as myuser;
import 'package:pasteleria_delicia/src/services/firebase_auth_service.dart';

// Enum para manejar los estados de la autenticación de forma clara
enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating, // Cargando durante el login
  registering, // Cargando durante el registro
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  myuser.UserModel? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;

  // Getters para que la UI pueda acceder al estado
  myuser.UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _status = AuthStatus.authenticating;
    notifyListeners();
    // Escuchamos los cambios de usuario en tiempo real desde el servicio
    _authService.user.listen((user) {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      if (_user != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      // Si el servicio devuelve null por alguna razón, lo marcamos como no autenticado
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      // Mapeamos códigos de error de Firebase a mensajes amigables
      _errorMessage = _mapAuthErrorToMessage(e.code);
      notifyListeners();
      return false;
    }
  }

  // Se actualiza el método signUp para aceptar el modelo de usuario completo
  Future<bool> signUp(myuser.UserModel userToRegister, String password) async {
    _status = AuthStatus.registering;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.registerWithEmailAndPassword(userToRegister, password);
      if (_user != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapAuthErrorToMessage(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Función de ayuda para traducir errores
  String _mapAuthErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se encontró un usuario con ese correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está en uso por otra cuenta.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
    }
  }
}
