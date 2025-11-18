import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Mientras se verifica el estado de autenticación, muestra un loader
    if (authProvider.status == AuthStatus.authenticating || authProvider.status == AuthStatus.uninitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si el usuario NO está autenticado, muestra las opciones de login/registro
    if (authProvider.user == null) {
      return _buildLoggedOutView(context);
    }

    // Si el usuario SÍ está autenticado, muestra el perfil completo
    return _buildLoggedInView(context, authProvider);
  }

  // Widget para la vista de usuario NO autenticado
  Widget _buildLoggedOutView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.bakery_dining_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Únete a Pastelería Delicia',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Inicia sesión para ver tus pedidos y gestionar tu cuenta.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.push('/login'), // Navega a la pantalla de login
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.push('/register'), // Navega a la pantalla de registro
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Crear Cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la vista de usuario autenticado
  Widget _buildLoggedInView(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
         backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push('/profile/edit', extra: user),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Teléfono'),
            subtitle: Text(user.phoneNumber ?? 'No especificado'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: const Text('Dirección de Envío'),
            subtitle: Text(
              user.shippingAddress != null
                  ? '${user.shippingAddress!.address}, ${user.shippingAddress!.city}, ${user.shippingAddress!.postalCode}'
                  : 'No especificada',
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
