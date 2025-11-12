import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pasteleria_delicia/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pasteleria_delicia/src/features/auth/presentation/screens/register_screen.dart';
import 'package:pasteleria_delicia/src/features/cart/presentation/screens/cart_screen.dart';
import 'package:pasteleria_delicia/src/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:pasteleria_delicia/src/features/home/presentation/screens/home_screen.dart';
import 'package:pasteleria_delicia/src/features/orders/presentation/screens/orders_screen.dart';
import 'package:pasteleria_delicia/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:pasteleria_delicia/src/common_widgets/scaffold_with_nav_bar.dart';
import 'package:pasteleria_delicia/src/features/products/presentation/screens/product_detail_screen.dart';
import 'package:pasteleria_delicia/src/models/product_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final product = state.extra as Product;
                  return ProductDetailScreen(product: product);
                },
              ),
            ]),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
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
);

