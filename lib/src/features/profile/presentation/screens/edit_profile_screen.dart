import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart' as myuser;
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final myuser.UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _addressController = TextEditingController(
      text: widget.user.shippingAddress?.address ?? '',
    );
    _cityController = TextEditingController(
      text: widget.user.shippingAddress?.city ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.user.shippingAddress?.postalCode ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Editar Perfil'),
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
                'Actualiza tu Información',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Nombre
              _buildTextField(
                _nameController,
                'Nombre Completo',
                Icons.person,
              ),
              
              // Teléfono
              _buildTextField(
                _phoneController,
                'Número de Teléfono',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              Text(
                'Dirección de Envío',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),

              // Dirección
              _buildTextField(
                _addressController,
                'Dirección (Calle y número)',
                Icons.home,
              ),

              // Ciudad
              _buildTextField(
                _cityController,
                'Ciudad',
                Icons.location_city,
              ),

              // Código Postal
              _buildTextField(
                _postalCodeController,
                'Código Postal',
                Icons.mail,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Guardar Cambios'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (label.contains('Nombre') || label.contains('Dirección') || label.contains('Ciudad')) {
            if (value == null || value.isEmpty) {
              return 'Por favor, completa este campo';
            }
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = FirestoreService();
      
      // Crear la dirección actualizada
      final updatedAddress = myuser.ShippingAddress(
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
      );

      // Crear el usuario actualizado
      final updatedUser = myuser.UserModel(
        uid: widget.user.uid,
        name: _nameController.text,
        email: widget.user.email,
        role: widget.user.role,
        profileImageUrl: widget.user.profileImageUrl,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        shippingAddress: updatedAddress,
      );

      // Guardar en Firestore
      await firestoreService.addUser(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil actualizado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      // Actualizar el AuthProvider
      context.read<AuthProvider>().updateUserProfile(updatedUser);

      // Volver a la pantalla anterior
      context.pop();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
