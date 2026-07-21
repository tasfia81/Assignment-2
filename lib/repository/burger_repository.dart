import 'dart:convert';
import 'package:get/get.dart';
import '../models/addon_model.dart';
import '../models/menu_item_model.dart';
import '../models/location_model.dart';
import '../services/database_service.dart';

/// Abstract contract for fetching menu products and store location data.
abstract class BurgerRepository {
  /// Fetches all available menu items (burgers, sides, drinks).
  Future<List<MenuItemModel>> getBurgers();

  /// Fetches items marked for featured highlights on the Home screen.
  Future<List<MenuItemModel>> getFeaturedBurgers();

  /// Fetches physical store branch locations across Pakistan.
  Future<List<LocationModel>> getBranches();
}

/// Production implementation of [BurgerRepository].
/// 
/// Implements an Offline-First caching strategy:
/// 1. Immediately returns locally cached JSON from Hive if available.
/// 2. Asynchronously fetches/refreshes fresh product data in the background.
class BurgerRepositoryImpl implements BurgerRepository {
  final DatabaseService _db = Get.find<DatabaseService>();

  // Standard customization add-on lists
  static final List<AddonModel> _smashedAddons = [
    AddonModel(id: 'add_patty', name: 'Extra Smashed Patty', price: 250.0, category: 'patty'),
    AddonModel(id: 'add_cheese', name: 'Extra Cheddar Slice', price: 80.0, category: 'cheese'),
  ];

  static final List<AddonModel> _generalAddons = [
    AddonModel(id: 'add_sauce', name: 'Extra House Sauce', price: 50.0, category: 'sauce'),
  ];

  // Mock catalog representing MUSTAV signature artisan products
  final List<MenuItemModel> _mockBurgers = [
    MenuItemModel(
      id: 'bg_original',
      name: 'MUSTAV Original',
      description: 'The definitive smash experience. Double prime beef patties smashed thin, double melted cheddar, caramelized onions, crisp pickles, and our signature burger sauce on toasted brioche.',
      price: 850.0,
      calories: 450,
      protein: 28.5,
      carbs: 34.0,
      fat: 19.5,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
      category: 'smashed',
      isFeatured: true,
      ingredients: ['Prime Beef', 'Cheddar Cheese', 'Signature Sauce', 'Pickles', 'Brioche Bun'],
      prepTime: '12 mins',
      spiceLevel: 'Mild',
      pattyType: 'Double Smashed Beef',
      availableAddons: _smashedAddons,
    ),
    MenuItemModel(
      id: 'bg_honey_glazed',
      name: 'Chili Honey Glazed',
      description: 'Sweet meets heat. Double smashed patties coated with our hot chili honey glaze, topped with melted cheddar, jalapeños, and crispy onion strings for an explosive flavor profile.',
      price: 950.0,
      calories: 480,
      protein: 29.0,
      carbs: 38.0,
      fat: 20.0,
      imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=600&q=80',
      category: 'smashed',
      isFeatured: true,
      ingredients: ['Prime Beef', 'Chili Honey Glaze', 'Cheddar Cheese', 'Jalapeños', 'Onion Strings'],
      prepTime: '14 mins',
      spiceLevel: 'Chili Honey',
      pattyType: 'Double Smashed Beef',
      availableAddons: _smashedAddons,
    ),
    MenuItemModel(
      id: 'bg_loaded_monster',
      name: 'The Loaded Monster',
      description: 'Triple smashed beef patties stacked tall with triple cheddar cheese, smoked beef bacon, caramelized onions, loaded pickles, and garlic aioli sauce. Built for the hungry.',
      price: 1250.0,
      calories: 680,
      protein: 42.0,
      carbs: 36.0,
      fat: 32.0,
      imageUrl: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?auto=format&fit=crop&w=600&q=80',
      category: 'smashed',
      isFeatured: true,
      ingredients: ['Triple Beef Patties', 'Triple Cheddar', 'Beef Bacon', 'Caramelized Onions', 'Garlic Aioli'],
      prepTime: '18 mins',
      spiceLevel: 'Medium',
      pattyType: 'Triple Smashed Beef',
      availableAddons: _smashedAddons,
    ),
    MenuItemModel(
      id: 'bg_classic_single',
      name: 'Classic Single',
      description: 'A light yet satisfying smash. Single beef patty smashed thin on the flat-top, melted cheddar, fresh lettuce, sliced tomatoes, and house mayo. Clean and organic.',
      price: 650.0,
      calories: 320,
      protein: 16.0,
      carbs: 31.0,
      fat: 11.5,
      imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?auto=format&fit=crop&w=600&q=80',
      category: 'smashed',
      isFeatured: false,
      ingredients: ['Single Beef Patty', 'Cheddar Cheese', 'Lettuce', 'Tomato', 'House Mayo'],
      prepTime: '10 mins',
      spiceLevel: 'None',
      pattyType: 'Single Smashed Beef',
      availableAddons: _smashedAddons,
    ),
    MenuItemModel(
      id: 'sd_loaded_fries',
      name: 'Loaded Smashed Fries',
      description: 'Our hand-cut golden fries loaded with smashed beef patty bits, melted cheddar cheese sauce, signature glaze, and sliced jalapeños.',
      price: 550.0,
      calories: 380,
      protein: 12.0,
      carbs: 45.0,
      fat: 16.0,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80',
      category: 'sides',
      isFeatured: false,
      ingredients: ['Hand-cut Fries', 'Beef Bits', 'Cheddar Cheese Sauce', 'Jalapeños'],
      prepTime: '8 mins',
      spiceLevel: 'Mild',
      pattyType: 'None',
      availableAddons: _generalAddons,
    ),
    MenuItemModel(
      id: 'sd_onion_rings',
      name: 'Crispy Onion Rings',
      description: 'Thick-cut onions beer-battered and fried until golden brown, served with a side of spicy honey dip.',
      price: 350.0,
      calories: 220,
      protein: 3.5,
      carbs: 28.0,
      fat: 9.0,
      imageUrl: 'https://images.unsplash.com/photo-1639024471283-27789a6a4a3c?auto=format&fit=crop&w=600&q=80',
      category: 'sides',
      isFeatured: false,
      ingredients: ['Crispy Onion Rings', 'Spicy Honey Dip'],
      prepTime: '7 mins',
      spiceLevel: 'None',
      pattyType: 'None',
      availableAddons: _generalAddons,
    ),
    MenuItemModel(
      id: 'dr_spiced_shake',
      name: 'Cardamom Spiced Shake',
      description: 'A premium, thick vanilla bean milkshake blended with subtle notes of cardamom and crushed roasted almonds. Est. Pakistani style.',
      price: 450.0,
      calories: 310,
      protein: 6.0,
      carbs: 42.0,
      fat: 12.0,
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      category: 'drinks',
      isFeatured: false,
      ingredients: ['Vanilla Bean Ice Cream', 'Cardamom', 'Almonds', 'Fresh Milk'],
      prepTime: '5 mins',
      spiceLevel: 'None',
      pattyType: 'None',
      availableAddons: [],
    ),
    MenuItemModel(
      id: 'dr_lemon_mint',
      name: 'Lemon Honey Mint Chiller',
      description: 'Super refreshing lemon juice blended with ice, fresh mint leaves, and organic honey. The perfect summer counterweight.',
      price: 350.0,
      calories: 90,
      protein: 0.5,
      carbs: 22.0,
      fat: 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'drinks',
      isFeatured: false,
      ingredients: ['Fresh Lemon', 'Mint Leaves', 'Organic Honey', 'Ice'],
      prepTime: '4 mins',
      spiceLevel: 'None',
      pattyType: 'None',
      availableAddons: [],
    ),
  ];

  // Physical branch store locations with precise GPS coordinates
  final List<LocationModel> _mockBranches = [
    LocationModel(
      id: 'br_lahore',
      name: 'Lahore Flagship Kitchen',
      address: 'Plot 24, Block Z, Phase 3, DHA, Lahore, Punjab',
      latitude: 31.4704, // Refined coordinate DHA Phase 6
      longitude: 74.4087,
      phone: '+92 42 111 687 828',
      openingHours: '12:00 PM - 2:00 AM',
    ),
    LocationModel(
      id: 'br_islamabad',
      name: 'Islamabad Capital Hub',
      address: 'Shop 10, F-11 Markaz, Islamabad, ICT',
      latitude: 33.6844,
      longitude: 73.0479,
      phone: '+92 51 111 687 828',
      openingHours: '12:00 PM - 1:00 AM',
    ),
    LocationModel(
      id: 'br_rawalpindi',
      name: 'Rawalpindi Saddar',
      address: 'Civic Center, Phase 4, Bahria Town, Rawalpindi, Punjab',
      latitude: 33.5984,
      longitude: 73.0441,
      phone: '+92 51 543 2109',
      openingHours: '1:00 PM - 3:00 AM',
    ),
    LocationModel(
      id: 'br_multan',
      name: 'Multan Gulgasht',
      address: '12-A, Gulgasht Colony, Multan, Punjab',
      latitude: 30.1575,
      longitude: 71.5249,
      phone: '+92 61 456 7890',
      openingHours: '12:00 PM - 12:00 AM',
    ),
  ];

  /// Retrieves the list of menu items.
  /// Uses a cache-first approach: reads cached JSON if present, then triggers a background fetch.
  @override
  Future<List<MenuItemModel>> getBurgers() async {
    final String? cachedJson = _db.appSettingsBox.get('cached_burgers') as String?;
    if (cachedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJson) as List<dynamic>;
        final list = decoded.map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>)).toList();
        
        // Background cache update to ensure data freshness
        _fetchAndCacheBurgers();
        return list;
      } catch (_) {
        // Fallback to fresh fetch if JSON deserialization fails
      }
    }
    return await _fetchAndCacheBurgers();
  }

  /// Internal helper to simulate network request latency and write updated product list into Hive cache.
  Future<List<MenuItemModel>> _fetchAndCacheBurgers() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final list = _mockBurgers;
    final String serialized = jsonEncode(list.map((e) => e.toJson()).toList());
    await _db.appSettingsBox.put('cached_burgers', serialized);
    return list;
  }

  /// Filters product list for items marked with `isFeatured: true`.
  @override
  Future<List<MenuItemModel>> getFeaturedBurgers() async {
    final burgers = await getBurgers();
    return burgers.where((b) => b.isFeatured).toList();
  }

  /// Fetches physical store branch locations.
  @override
  Future<List<LocationModel>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBranches;
  }
}
