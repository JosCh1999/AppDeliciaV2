# 🍰 Pastelería Delicia - Aplicación Flutter

Una aplicación móvil moderna de e-commerce para una pastelería, desarrollada con **Flutter** y **Firebase**.

## 📱 Características Principales

### ✨ Funcionalidades Implementadas
- 🔐 **Autenticación Firebase**: Login/Register con validación
- 🏠 **Catálogo de productos**: Visualización con imágenes y stock
- 🛒 **Carrito de compras**: Gestión de items con cantidad
- 📦 **Sistema de órdenes**: Creación y seguimiento de pedidos
- 🚚 **Opciones de envío**: Delivery (+S/5.00) o Recojo en tienda (Gratis)
- 👤 **Perfil de usuario**: Edición de información y dirección
- 📊 **Stock management**: Descuento automático al entregar
- 🔄 **Sincronización en tiempo real**: Órdenes actualizadas automáticamente
- 💰 **Checkout completo**: Desglose de precios con opciones de envío

### 🎨 UX/UI Mejorado
- Interfaz moderna con Material Design 3
- Colores consistentes (rosa/magenta brand)
- Animaciones suaves y transiciones
- Responsive design para diferentes tamaños
- Estados vacíos con iconografía clara
- Loading states optimizados

## 🏗️ Arquitectura

```
lib/
├── main.dart                 # Punto de entrada
├── firebase_options.dart     # Configuración Firebase
├── src/
│   ├── models/              # Modelos de datos (Product, Order, User)
│   ├── services/            # Lógica Firebase (Auth, Firestore, Stock)
│   ├── providers/           # State management (Provider pattern)
│   ├── features/            # UI por feature (Auth, Cart, Orders, etc.)
│   ├── common_widgets/      # Widgets reutilizables
│   └── core/
│       ├── routing/         # GoRouter configuration
│       └── theme/           # Temas y estilos
```


## 🛠️ Requisitos

- **Flutter**: 3.16+ 
- **Dart**: 3.2+
- **Android SDK**: API 21+ (Android 5.0)
- **iOS**: 11.0+ (si aplica)
- **Firebase Account**: Para backend

## 📦 Instalación

### 1. Clonar el repositorio
```bash
git clone <tu-repo>
cd AppDeliciaV2
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Generar APK
```bash
# APK en modo debug
flutter build apk --debug

# APK en modo release (recomendado para producción)
flutter build apk --release

# Archivo APK estará en: build/app/outputs/flutter-apk/app-release.apk
```

### 4. Instalar en dispositivo
```bash
flutter install
```

## 🚀 Compilación para Producción

### APK Release
```bash
flutter build apk --release
```

### App Bundle (para Google Play)
```bash
flutter build appbundle --release
```

### Ubicación de salida
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`

## 🔧 Configuración Firebase

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Storage (opcional para imágenes)
3. Descargar `google-services.json` para Android
4. Copiar a `android/app/google-services.json`

## 📊 Estructura Firestore

```
users/
  {uid}
    - name: string
    - email: string
    - phone: string
    - shippingAddress: { address, city, postalCode }

products/
  {productId}
    - name: string
    - description: string
    - price: number
    - imageUrl: string
    - stock: number
    - category: string

orders/
  {orderId}
    - userId: string
    - items: array
    - totalAmount: number
    - status: string (pendiente, en preparación, entregado, cancelado)
    - createdAt: timestamp
    - shippingAddress: object
```

## 🚨 Troubleshooting

### Build Falla
```bash
# Limpiar completamente
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter run
```

### Assets no encuentran
- Verificar `pubspec.yaml` contiene paths correctos
- Re-ejecutar `flutter pub get`

### Firestore Connection Error
- Verificar `google-services.json` está en `android/app/`
- Verificar reglas Firestore permiten acceso
- Probar conexión internet


## 👨‍💻 Stack Tecnológico

### Frontend
- **Flutter**: Framework UI
- **Provider**: State management
- **GoRouter**: Routing declarativo
- **google_fonts**: Tipografía

### Backend
- **Firebase Authentication**: Autenticación
- **Cloud Firestore**: Base de datos NoSQL
- **Firebase Cloud Storage**: Almacenamiento (opcional)

### Herramientas
- **Dart**: Lenguaje de programación
- **Git**: Control de versiones
- **VS Code/Android Studio**: IDE


## 📝 Licencia

MIT - Libre para uso personal y educativo

## 🤝 Contribuciones

Este proyecto es educativo. Para cambios importantes, por favor abre un issue primero.


**Versión**: 1.0.0  
**Último Update**: Noviembre 2025  
**Estado**: ✅ Listo para Producción MVP
