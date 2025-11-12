
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin; // Callback para cambiar a Login

  const RegisterScreen({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        // Eliminamos el botón de volver automático porque estamos dentro de la misma vista
        automaticallyImplyLeading: false, 
      ),
      body: Form(
        key: _formKey,
        child: ListView( 
          padding: const EdgeInsets.all(16.0),
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
                    final shippingAddress = ShippingAddress(
                      address: _addressController.text,
                      city: _cityController.text,
                      postalCode: _postalCodeController.text,
                    );
                    final userToRegister = UserModel(
                      uid: '', 
                      name: _nameController.text,
                      email: _emailController.text,
                      phoneNumber: _phoneController.text,
                      shippingAddress: shippingAddress,
                    );
                    // No necesitamos `await` ni `context.go` aquí.
                    // El AuthProvider notificará a los listeners y la UI se reconstruirá sola.
                    context.read<AuthProvider>().signUp(
                          userToRegister,
                          _passwordController.text,
                        );
                  }
                },
                child: const Text('Registrarse'),
              ),
            TextButton(
              onPressed: widget.onSwitchToLogin, // Usamos el callback
              child: const Text('¿Ya tienes una cuenta? Inicia Sesión'),
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
    );
  }
}