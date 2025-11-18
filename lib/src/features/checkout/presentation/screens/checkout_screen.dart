import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteleria_delicia/src/providers/auth_provider.dart';
import 'package:pasteleria_delicia/src/providers/cart_provider.dart';
import 'package:pasteleria_delicia/src/providers/order_provider.dart';
import 'package:pasteleria_delicia/src/providers/shipping_provider.dart';
import 'package:pasteleria_delicia/src/models/order_model.dart';
import 'package:pasteleria_delicia/src/models/shipping_type_model.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final shippingProvider = context.watch<ShippingProvider>();
    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final theme = Theme.of(context);

    final subtotal = cartProvider.totalAmount;
    final shippingCost = shippingProvider.shippingCost;
    final total = subtotal + shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Resumen de productos
              _buildOrderSummary(context, cartProvider),
              const SizedBox(height: 28),

              // Opciones de envío
              _buildShippingOptions(context, shippingProvider, theme),
              const SizedBox(height: 28),

              // Desglose de precios
              _buildPriceSummary(context, subtotal, shippingCost, total, theme),
              const SizedBox(height: 40),

              // Botón de finalizar compra
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleCheckout(
                    context,
                    cartProvider,
                    authProvider,
                    orderProvider,
                    shippingProvider,
                    total,
                  ),
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: const Text('FINALIZAR COMPRA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📦 Resumen del Pedido',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cantidad: ${item.quantity}x \$${item.product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShippingOptions(BuildContext context, ShippingProvider shippingProvider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚚 Tipo de Envío',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RadioListTile<ShippingType>(
                  title: const Text('🏠 Delivery', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Entrega a domicilio'),
                  value: ShippingType.delivery,
                  groupValue: shippingProvider.shippingType,
                  onChanged: (value) {
                    if (value != null) {
                      shippingProvider.setShippingType(value);
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '+S/. ${ShippingType.delivery.cost.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 24),
                RadioListTile<ShippingType>(
                  title: const Text('🏪 Recojo en tienda', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Sin costo adicional'),
                  value: ShippingType.pickup,
                  groupValue: shippingProvider.shippingType,
                  onChanged: (value) {
                    if (value != null) {
                      shippingProvider.setShippingType(value);
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '✓ Gratis',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context, double subtotal, double shippingCost, double total, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '💰 Desglose de Precios',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                Text('\$${subtotal.toStringAsFixed(2)}', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Envío:', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                Text(
                  '+\$${shippingCost.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    color: shippingCost > 0 ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 2,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
    OrderProvider orderProvider,
    ShippingProvider shippingProvider,
    double totalAmount,
  ) async {
    if (authProvider.user == null) {
      context.go('/profile');
      return;
    }

    final user = authProvider.user!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final newOrder = OrderModel(
        userId: user.uid,
        items: cartProvider.items,
        totalAmount: totalAmount,
        shippingAddress: ShippingAddress(
          name: user.name,
          address: user.shippingAddress?.address ?? '123 Calle Falsa',
          city: user.shippingAddress?.city ?? 'Springfield',
          postalCode: user.shippingAddress?.postalCode ?? '12345',
        ),
        createdAt: Timestamp.now(),
      );

      await orderProvider.addOrder(newOrder);
      cartProvider.clearCart();
      shippingProvider.reset();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('✅ ¡Pedido realizado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/orders');
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al crear el pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
