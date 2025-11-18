import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pasteleria_delicia/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pasteleria_delicia/src/features/auth/presentation/screens/register_screen.dart';
import 'package:pasteleria_delicia/src/features/cart/presentation/screens/cart_screen.dart';
import 'package:pasteleria_delicia/src/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:pasteleria_delicia/src/features/home/presentation/screens/home_screen.dart';
import 'package:pasteleria_delicia/src/features/orders/presentation/screens/orders_screen.dart';
import 'package:pasteleria_delicia/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:pasteleria_delicia/src/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:pasteleria_delicia/src/common_widgets/scaffold_with_nav_bar.dart';
import 'package:pasteleria_delicia/src/features/products/presentation/screens/product_detail_screen.dart';
import 'package:pasteleria_delicia/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:pasteleria_delicia/src/models/product_model.dart';
import 'package:pasteleria_delicia/src/models/user_model.dart' as myuser;

// Claves de navegación para gestionar las pilas de rutas
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Ruta del splash screen
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),

    // Ruta de producto detalle (fuera del shell)
    GoRoute(
      path: '/product/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final product = state.extra as Product;
        return ProductDetailScreen(product: product);
      },
    ),

    // Ruta de editar perfil (fuera del shell)
    GoRoute(
      path: '/profile/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final user = state.extra;
        if (user is myuser.UserModel) {
          return EditProfileScreen(user: user);
        }
        return const ProfileScreen();
      },
    ),

    // La ruta Shell que gestiona la navegación principal con la barra inferior
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  // Añadimos un gestor de errores para facilitar la depuración futura
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Página no encontrada')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('La ruta \'${state.uri}\' no existe.\nError: ${state.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Ir al inicio'),
          )
        ],
      ),
    ),
  ),
);
