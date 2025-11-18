# Copilot Instructions for Pastelería Delicia

## Project Overview
**Pastelería Delicia** is a Flutter e-commerce app for pastries and cakes, integrating Firebase for authentication, Firestore for data, and Provider for state management. The app follows a clean architecture with separated concerns: services (Firebase logic), providers (state management), and features (UI layer organized by domain).

## Architecture & Key Components

### Layered Structure
- **Models** (`lib/src/models/`): Data classes with `toMap()/fromMap()` for Firestore serialization
- **Services** (`lib/src/services/`): Firebase business logic (auth, Firestore, product ops) - pure data layer
- **Providers** (`lib/src/providers/`): ChangeNotifier classes managing UI state, using streams from services
- **Features** (`lib/src/features/`): Feature-based directories (auth, cart, products, orders, profile) containing only UI/presentation

### Critical Data Flows
1. **Auth Flow**: `FirebaseAuthService` (real-time auth state) → `AuthProvider` (UI state with enum `AuthStatus`) → Login/Register screens
2. **Order Sync**: `OrderProvider` listens to auth changes via `ChangeNotifierProxyProvider` in `main.dart` to auto-fetch/clear user orders on login/logout
3. **Product-to-Cart**: `ProductService` streams products → `CartProvider` stores selections locally → `OrderService` persists to Firestore on checkout

### ProxyProvider Pattern
Used in `main.dart` for `OrderProvider` to react to `AuthProvider` changes:
```dart
ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
  create: (_) => OrderProvider(),
  update: (_, auth, previous) {
    if (auth.user != null) orderProvider.fetchOrdersForUser(auth.user!.uid);
    else orderProvider.clearOrders();
    return orderProvider;
  }
)
```
This ensures orders sync when users log in/out without manual triggers.

## State Management Conventions

### Providers Pattern
- **Stateful**: Use `ChangeNotifier` when UI depends on state changes (`AuthProvider`, `CartProvider`, `OrderProvider`)
- **State as Enums**: Use enums for multi-state workflows (see `AuthStatus` in `auth_provider.dart` with states: `uninitialized`, `authenticating`, `authenticated`, `unauthenticated`, `error`)
- **Error Tracking**: Each provider has `_errorMessage` field; always set errors during exception handling
- **Getters for UI**: Expose state via getters only; never allow direct mutation from UI

### Service Layer Rules
- Services are **Firebase-only wrappers** - no business logic, no UI concerns
- Always return typed objects (e.g., `Future<UserModel>`, not `Future<Map>`)
- Use streams where real-time updates are needed (products, auth state)
- Handle Firebase exceptions, throw domain-specific types if needed

## Routing with GoRouter

### Structure
- **Top-level routes**: `/login`, `/register` (use `parentNavigatorKey` to show full-screen)
- **Shell routes**: Nested under main shell for bottom nav bar (home, cart, orders, profile)
- **Nested detail routes**: Product details nest under home (`/product/:id`), passed via `state.extra as Product`
- **Error handling**: Custom error builder returns 404 page with navigation back to `/`

Key file: `lib/src/core/routing/app_router.dart` defines all route structure.

## Feature Organization

Each feature follows this structure:
```
features/<feature_name>/
  presentation/
    screens/        # Full-page widgets
    widgets/        # Reusable components
    [models/]       # Feature-specific models if any
```

Example: `features/auth/presentation/screens/login_screen.dart` depends on `AuthProvider` to handle state.

## Firestore Data Models & Conventions

### Collection Structure
- **users**: User profiles with embedded `shippingAddress` (nested object with address, city, postalCode)
- **products**: Product catalog (name, description, price, imageUrl)
- **orders**: User orders (userId, items, totalPrice, status, createdAt, shippingAddress)

### Model Serialization
All models implement:
- `toMap()` → converts to `Map<String, dynamic>` for Firestore writes
- `factory Model.fromDocument(DocumentSnapshot doc)` → deserializes from Firestore
- Nested objects (e.g., `ShippingAddress` in `UserModel`) have their own `toMap()/fromMap()`

## Development Workflow

### Building & Running
```bash
flutter pub get              # Install dependencies
flutter run                  # Run app on device/emulator
```

### Firebase Setup
- `firebase_options.dart` is auto-generated; regenerate if adding new Firebase services
- Android credentials in `android/app/google-services.json` (Git-ignored)

### State Debugging
- Use `AuthProvider` enum status to debug auth flow
- Check `CartProvider` for cart state; always verify `_items` list before checkout
- Use Firestore console to verify data written by services

## Common Patterns & Gotchas

### 1. Enum-Based Status in Providers
Always use `AuthStatus` enum (not boolean `isLoading`) for clarity:
- `uninitialized` → app startup
- `authenticating/registering` → in-progress
- `authenticated/unauthenticated` → final state
- `error` → failure occurred

Example UI pattern:
```dart
if (authProvider.status == AuthStatus.authenticated) {
  // Show main app
} else if (authProvider.status == AuthStatus.authenticating) {
  // Show loading
} else {
  // Show login screen
}
```

### 2. Nested ShippingAddress Model
When updating user in Firestore:
```dart
user.copyWith(
  shippingAddress: ShippingAddress(address: "...", city: "...", postalCode: "...")
)
```
The model handles serialization via `toMap()` automatically.

### 3. Product Detail Navigation
Pass product as `state.extra` to avoid serialization issues with complex objects:
```dart
context.push('/product/$id', extra: product);  // In route builder: state.extra as Product
```

### 4. Real-Time Streams in UI
Services return `Stream<List<T>>` for live updates. Wrap with `StreamBuilder` in widgets:
```dart
StreamBuilder<List<Product>>(
  stream: productService.getProducts(),
  builder: (_, snapshot) => snapshot.data ?? []
)
```

## File References for Key Patterns

- **Auth flow**: `lib/src/services/firebase_auth_service.dart`, `lib/src/providers/auth_provider.dart`
- **Order sync on login**: `lib/main.dart` (ProxyProvider logic)
- **Product catalog**: `lib/src/services/product_service.dart`, `lib/src/features/products/`
- **Routing**: `lib/src/core/routing/app_router.dart`
- **Models**: `lib/src/models/user_model.dart` (see ShippingAddress nested model pattern)

## Tips for AI Agents

When modifying this codebase:
1. Always update both model serialization (`toMap()` and `fromMap()`) when adding fields
2. Keep services Firebase-specific; move business logic to providers
3. Use ProxyProvider for cross-provider dependencies (don't pass providers as parameters)
4. Test auth state changes in `main.dart`'s ProxyProvider when adding order-related features
5. Verify Firestore rules match expected data access patterns (users should only read their own data)
