# MUSTAV Artisan Burgers Mobile Application

A premium, production-ready native mobile experience of **MUSTAV Smashed Burgers** built in Flutter using Clean Architecture, GetX, Hive, and Google Maps.

---

## 🎨 Design Theme & Branding
The application uses a **High-End Premium Dark Theme**:
- **Scaffold Background**: Deep Velvet Black (`#0B0B0B`)
- **Card Surfaces**: Charcoal Dark (`#1E1E1E` & `#2C2C2E`)
- **Primary & Accent Highlighting**: Metallic Gold (`#D4AF37`)
- **Typography**: Google Fonts `Outfit` (Modern Sans-Serif) with clean rounded borders.

---

## 🚀 Key Features

### 1. Custom Animated Splash Screen
- **Color Swipe Slides**: Slides responsive backgrounds in transition.
- **Custom Painter Animation**: Animates individual burger elements (patty, lettuce, cheese, top bun) falling onto a flat grill canvas in real-time.

### 2. Responsive Menu Catalog
- **Search & Filtering**: Search bar checks names, descriptions, patty builds, and ingredients, resetting pagination visible arrays.
- **Category Filter Chips**: Switches active food categories reactively.
- **Lazy Loading list**: Listeners append pages of size `4` near scroll bottom, displaying spinner loading indicators.
- **Image Caching**: Prevents redownloads using `CachedNetworkImage` memory limits.

### 3. Detailed Product Customization
- **Typed Addons**: Toggles extra cheese slices, extra smashed patties, or garlic dips.
- **Ingredient Exclusions**: Excludes onions specifically for smashed burger lines.
- **Special Instructions**: Adds custom text fields for kitchen notes.

### 4. Offline Banner & Checkout Safeguards
- **Real-Time Banner**: Floating warning appears immediately when connectivity is lost.
- **Checkout Disables**: Form button locks when connection fails, allowing local cart edits and offline catalog browsing.
- **Network Glitch Handler**: If transaction submit fails, items are kept in the cart and a retry checkout button is displayed.
- **Auto-Refresh**: Syncs catalog data once internet connection is restored.

### 5. Persistent Local Cart
- Saves cart data immediately to Hive on insertion, count update, or deletion.
- Survives device reboots, force kills, and background suspension.

### 6. Location Permissions & Nearest Branch
- Queries GPS coordinates via `Geolocator`.
- Calculates distances in kilometers to Islamabad, Lahore, Rawalpindi, and Multan kitchens.
- Sorts and displays the closest branch location automatically.
- Fallback manual picker provided when GPS permission is denied.

---

## 🏗️ Folder Structure
The codebase follows a Clean Architecture structure:

```text
lib/
├── core/
│   ├── network/      # Connectivity and Network Info
│   ├── theme/        # AppColors and AppTypography
│   └── values/       # Constants
├── data/             # Models and local API implementations
├── models/           # Strongly typed domain objects (no dynamic)
├── modules/          # Feature UI modules and GetX Controllers
│   ├── auth/
│   ├── cart/
│   ├── details/
│   ├── home/
│   ├── map/
│   ├── splash/
│   └── tracking/
├── repository/       # Data Access Layer & Cache policies
├── routes/           # Routing configuration maps
├── services/         # Platform hooks (Hive, Geolocator, Notifications)
└── widgets/          # Shared Reusable Widgets Kit
```

---

## 📦 Packages Used
- **get**: State management, routing and Dependency Injection.
- **hive_flutter**: High performance offline key-value storage.
- **google_maps_flutter**: Interactive maps.
- **geolocator**: Distance calculation and coordinate tracking.
- **connectivity_plus**: Real-time network listener.
- **flutter_local_notifications**: Background status alerts.
- **cached_network_image**: Network assets optimization.
- **flutter_screenutil**: Multi-device layout adaptation.
- **google_fonts**: Outfit typography.
- **uuid**: Unique cart and order identifier tokens.

---

## 🛠️ Offline & Caching Strategy
1. **Cache-First**: On database queries, the repository reads cached catalog JSON from Hive boxes to render screens immediately, updating the database record in the background.
2. **Connectivity Listener**: If network state changes to `none`, `ConnectivityService` sets `isOffline` to `true`, forcing the UI to display the `OfflineBanner` and disable checkouts.
3. **Cart Preservation**: The cart JSON is written to Hive on every change. If a transaction fails or the device shuts down, no state is lost.

---

## 💾 Memory Optimization
- **CachedNetworkImage Limits**: Limits image disk cache dimensions (`maxWidthDiskCache: 600`) to prevent high RAM allocation.
- **Controller Lifecycle Management**: Disposes controllers, ScrollControllers, and timers in `onClose()` calls to prevent leaks.
