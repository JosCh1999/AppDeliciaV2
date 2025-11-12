
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pasteleria_delicia/src/features/home/presentation/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}
