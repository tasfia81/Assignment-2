import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/menu_item_model.dart';
import '../../models/location_model.dart';
import '../../models/user_model.dart';
import '../../repository/burger_repository.dart';
import '../../repository/auth_repository.dart';
import '../../routes/app_pages.dart';

/// View Controller for the Home Catalog Screen.
/// 
/// Manages category filtering, search queries, infinite scroll lazy loading,
/// branch location list retrieval, and user session state.
class HomeController extends GetxController {
  final BurgerRepository _burgerRepository = Get.find<BurgerRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  /// Indicates full page loading (initial fetch).
  final isLoading = true.obs;

  /// Indicates active lazy-loading pagination fetch at the bottom of the list.
  final isLazyLoading = false.obs;
  
  /// Selected category filter (e.g. 'all', 'smashed', 'sides', 'drinks').
  final selectedCategory = 'all'.obs;

  /// Active search query entered by the user.
  final searchQuery = ''.obs;

  /// Complete list of loaded products from repository.
  final burgers = <MenuItemModel>[].obs;

  /// Highlighted featured burgers displayed in hero banner.
  final featuredList = <MenuItemModel>[].obs;

  /// Available physical branch store locations.
  final branches = <LocationModel>[].obs;

  /// Currently logged in user profile.
  final currentUser = Rxn<UserModel>();

  // Lazy Loading Pagination State
  /// Subset of products currently visible to the UI.
  final visibleBurgers = <MenuItemModel>[].obs;
  final int _pageSize = 4;
  int _currentPage = 1;
  
  /// Scroll controller attached to the home ListView for bottom detection.
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadData();
    scrollController.addListener(_scrollListener);
  }

  /// Listens to scroll events and triggers [loadMoreBurgers] when near bottom edge.
  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
      loadMoreBurgers();
    }
  }

  /// Fetches all required home screen data concurrently from repositories.
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // 1. Fetch authenticated user details
      currentUser.value = await _authRepository.getCurrentUser();
      
      // 2. Fetch full burger menu catalog
      final allBurgers = await _burgerRepository.getBurgers();
      burgers.assignAll(allBurgers);

      // 3. Extract featured items for top banner
      final featured = allBurgers.where((b) => b.isFeatured).toList();
      featuredList.assignAll(featured);

      // 4. Load store branch locations
      final branchList = await _burgerRepository.getBranches();
      branches.assignAll(branchList);

      // 5. Initialize first page of lazy-loaded list
      resetPagination();
    } catch (_) {
      Get.snackbar('Error', 'Failed to load menu. Please refresh.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates active category filter and resets visible items page.
  void changeCategory(String category) {
    selectedCategory.value = category;
    resetPagination();
  }

  /// Updates active search query and recalculates visible items.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    resetPagination();
  }

  /// Computed property filtering the master product list by category & search query.
  List<MenuItemModel> get filteredBurgers {
    List<MenuItemModel> list = burgers;

    // 1. Filter by category
    if (selectedCategory.value != 'all') {
      list = list.where((b) => b.category == selectedCategory.value).toList();
    }

    // 2. Filter by search query across name, description, patty type, & ingredients
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((b) =>
          b.name.toLowerCase().contains(query) ||
          b.description.toLowerCase().contains(query) ||
          b.pattyType.toLowerCase().contains(query) ||
          b.ingredients.any((ing) => ing.toLowerCase().contains(query))).toList();
    }

    return list;
  }

  /// Resets pagination state to page 1 and loads initial page subset into [visibleBurgers].
  void resetPagination() {
    _currentPage = 1;
    final filtered = filteredBurgers;
    if (filtered.length <= _pageSize) {
      visibleBurgers.assignAll(filtered);
    } else {
      visibleBurgers.assignAll(filtered.sublist(0, _pageSize));
    }
  }

  /// Appends the next page slice of items to [visibleBurgers] upon scrolling.
  Future<void> loadMoreBurgers() async {
    if (isLazyLoading.value) return;

    final filtered = filteredBurgers;
    if (visibleBurgers.length >= filtered.length) return; // All items loaded

    isLazyLoading.value = true;

    // Simulate network delay for smooth UX loading indicator
    await Future.delayed(const Duration(milliseconds: 800));

    final int nextStart = _currentPage * _pageSize;
    final int nextEnd = nextStart + _pageSize;

    if (nextStart < filtered.length) {
      final int actualEnd = nextEnd > filtered.length ? filtered.length : nextEnd;
      visibleBurgers.addAll(filtered.sublist(nextStart, actualEnd));
      _currentPage++;
    }

    isLazyLoading.value = false;
  }

  /// Checks if there are more filtered items remaining beyond the currently visible slice.
  bool get hasMoreItems {
    return visibleBurgers.length < filteredBurgers.length;
  }

  /// Logs out current user and redirects to authentication view.
  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
