
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart'; // Importar UserModel y ShippingAddress

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // Nuevo controlador
  final _addressController = TextEditingController(); // Nuevo controlador
  final _cityController = TextEditingController(); // Nuevo controlador
  final _postalCodeController = TextEditingController(); // Nuevo controlador

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Usar ListView para evitar overflow
            children: [
              const Text("Información de la Cuenta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su nombre' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'La contraseña debe tener al menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text("Información de Contacto y Envío", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                 validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su teléfono' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                 validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su dirección' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                 validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su ciudad' : null,
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Código Postal'),
                keyboardType: TextInputType.number,
                 validator: (value) =>
                    value!.isEmpty ? 'Por favor, ingrese su código postal' : null,
              ),
              const SizedBox(height: 30),
              if (authProvider.status == AuthStatus.registering)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Crear el objeto de dirección
                      final shippingAddress = ShippingAddress(
                        address: _addressController.text,
                        city: _cityController.text,
                        postalCode: _postalCodeController.text,
                      );

                      // Crear el objeto de usuario con toda la información
                      final userToRegister = UserModel(
                        uid: '', // El UID se asignará después de crear el usuario en Firebase Auth
                        name: _nameController.text,
                        email: _emailController.text,
                        phoneNumber: _phoneController.text,
                        shippingAddress: shippingAddress,
                      );
                      
                      // Llamar al método de registro
                      final success = await context.read<AuthProvider>().signUp(
                            userToRegister,
                            _passwordController.text,
                          );

                      if (success && mounted) {
                        context.go('/'); // Navegar al home si el registro es exitoso
                      }
                    }
                  },
                  child: const Text('Registrarse'),
                ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('¿Ya tienes una cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}