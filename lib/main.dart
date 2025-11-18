import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pasteleria_delicia/firebase_options.dart'; 
import 'package:pasteleria_delicia/src/core/routing/app_router.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/providers/cart_provider.dart';
import 'package:pasteleria_delicia/src/providers/order_provider.dart';
import 'package:pasteleria_delicia/src/providers/order_status_provider.dart';
import 'package:pasteleria_delicia/src/providers/shipping_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ShippingProvider()),
        ChangeNotifierProvider(create: (_) => OrderStatusProvider()),
        
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (context) => OrderProvider(),
          update: (context, auth, previousOrderProvider) {
            final orderProvider = previousOrderProvider!;
            
            // **LÓGICA MEJORADA**: Detectar el inicio de sesión
            // Si antes no había usuario y ahora sí, es un nuevo login.
            if (auth.user != null) {
                debugPrint('📦 [ProxyProvider] Auth user changed. Fetching orders for: ${auth.user!.uid}');
                // Le decimos al OrderProvider que cargue los pedidos para el nuevo usuario
                // Usar forceRefresh=true para asegurar que siempre cargue los pedidos
                orderProvider.fetchOrdersForUser(auth.user!.uid, forceRefresh: true);
            } else {
                debugPrint('📦 [ProxyProvider] Auth user cleared. Clearing orders.');
                // Si no hay usuario (logout), limpiamos los pedidos
                orderProvider.clearOrders();
            }

            return orderProvider;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Pastelería Delicia',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.pink,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
