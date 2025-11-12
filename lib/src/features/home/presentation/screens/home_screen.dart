import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pasteleria_delicia/src/models/product_model.dart';
import 'package:pasteleria_delicia/src/providers/cart_provider.dart';
import 'package:pasteleria_delicia/src/services/product_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pastelería Delicia', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => context.go('/cart'),
                ),
              );
            },
          ),
        ],
      ),
      body: TiledNoiseBackground(
        child: StreamBuilder<List<Product>>(
          stream: productService.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No hay productos disponibles.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await productService.addSampleProducts();
                      },
                      child: const Text('Cargar productos de ejemplo'),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(product: product);
              },
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => context.go('/product/${product.id}', extra: product),
            child: _buildImageWithOverlay(context, theme),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _buildAddToCartButton(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithOverlay(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
          child: Image.network(
            product.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.bakery_dining, color: Colors.grey, size: 60),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Text(
            product.name,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context, ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: () {
        final cartProvider = context.read<CartProvider>();
        cartProvider.addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} fue añadido al carrito.'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'VER CARRITO',
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      },
      icon: const Icon(Icons.add_shopping_cart, size: 20),
      label: const Text('Añadir al Carrito'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TiledNoiseBackground extends StatelessWidget {
  final Widget child;
  const TiledNoiseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.background,
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/noise.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.05,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
