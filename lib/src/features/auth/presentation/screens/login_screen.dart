
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitchToRegister;

  const LoginScreen({super.key, required this.onSwitchToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Por favor, ingrese su email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Por favor, ingrese su contraseña' : null,
                ),
                const SizedBox(height: 20),
                if (authProvider.status == AuthStatus.authenticating)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthProvider>().signIn(
                              _emailController.text,
                              _passwordController.text,
                            );
                      }
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                TextButton(
                  onPressed: widget.onSwitchToRegister,
                  child: const Text('¿No tienes una cuenta? Regístrate'),
                ),
                if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
