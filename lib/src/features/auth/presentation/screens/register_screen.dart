import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart' as myuser;
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para todos los campos del formulario
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Crear Cuenta'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¡Bienvenido a Pastelería Delicia!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Completa tus datos para empezar.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // --- Campos del Formulario ---
              _buildTextField(_nameController, 'Nombre Completo'),
              _buildTextField(_emailController, 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
              _buildTextField(_passwordController, 'Contraseña', obscureText: true),
              _buildTextField(_phoneController, 'Número de Teléfono', keyboardType: TextInputType.phone),
              
              const SizedBox(height: 24),
              Text('Dirección de Envío', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              _buildTextField(_addressController, 'Dirección (Calle y número)'),
              _buildTextField(_cityController, 'Ciudad'),
              _buildTextField(_postalCodeController, 'Código Postal', keyboardType: TextInputType.number),
              
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    try {
                      // 1. Crear el objeto de dirección de envío
                      final shippingAddress = myuser.ShippingAddress(
                        address: _addressController.text,
                        city: _cityController.text,
                        postalCode: _postalCodeController.text,
                      );

                      // 2. Crear el objeto de usuario completo
                      final userToRegister = myuser.UserModel(
                        uid: '', // Se asignará por Firebase
                        name: _nameController.text,
                        email: _emailController.text,
                        phoneNumber: _phoneController.text,
                        shippingAddress: shippingAddress,
                        role: 'cliente', // Rol por defecto
                      );

                      // 3. Llamar al proveedor de autenticación
                      final success = await authProvider.signUp(
                        userToRegister,
                        _passwordController.text,
                      );

                      // 4. Si fue exitoso, redirigir al carrito para finalizar el pedido
                      if (success && mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('¡Cuenta creada exitosamente!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Redirigir al carrito después de 1 segundo
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (mounted) context.go('/cart');
                      }

                      if (!success && !mounted) return;

                      if (!success) {
                        // Si falló, mostrar el error del AuthProvider
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(authProvider.errorMessage ?? 'Error al registrarse'),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Iniciar Sesión',
                              onPressed: () => context.go('/login'),
                            ),
                          ),
                        );
                      }

                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Error inesperado: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Registrarse'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Corregido: Usar push para mantener la pila de navegación
                  context.push('/auth/login');
                },
                child: const Text('¿Ya tienes una cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper para no repetir código en los campos de texto
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, completa este campo';
          }
          if (label == 'Correo Electrónico' && !value.contains('@')) {
             return 'Ingresa un correo válido';
          }
          if (label == 'Contraseña' && value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
    );
  }
}