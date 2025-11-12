
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Mientras se verifica el estado de autenticación, muestra un loader
    if (authProvider.status == AuthStatus.authenticating || authProvider.status == AuthStatus.uninitialized) {
      // Devuelve un Scaffold para mantener la estructura de la app (con AppBar)
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Si el usuario NO está autenticado, muestra la pantalla de Login DENTRO de esta misma vista
    if (authProvider.status == AuthStatus.unauthenticated || authProvider.user == null) {
      return const LoginScreen(); 
    }

    // Si el usuario está autenticado, obtenemos los datos
    final user = authProvider.user!;

    // Si el usuario SÍ está autenticado, muestra el perfil completo
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              // No es necesario navegar, el widget se reconstruirá automáticamente
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
