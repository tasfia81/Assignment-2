import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../routes/app_pages.dart';
import '../../services/cart_service.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_text.dart';
import '../../widgets/burger_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/cart_badge.dart';
import '../../widgets/marquee_widget.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/primary_app_bar.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = Get.find<CartService>();
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: PrimaryAppBar(
        title: 'MUSTAV',
        leading: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.gold),
          onPressed: () => _showLogoutDialog(context),
        ),
        actions: [
          // Cart Badge
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.cart),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Obx(() => CartBadge(
                    count: cartService.totalQuantity,
                    child: const Icon(Icons.shopping_cart_outlined, color: AppColors.gold),
                  )),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // Offline banner warnings
            if (connectivityService.isOffline.value) const OfflineBanner(),
            
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : RefreshIndicator(
                      onRefresh: controller.loadData,
                      color: AppColors.gold,
                      backgroundColor: AppColors.surface,
                      child: SingleChildScrollView(
                        controller: controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Greeting
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: AppText(
                                'WANT A SMASH, ${controller.currentUser.value?.name.toUpperCase() ?? "CHAMP"}?',
                                variant: AppTextVariant.h2,
                                color: AppColors.white,
                              ),
                            ),
                            
                            // Reusable Search Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: AppSearchBar(
                                onChanged: controller.updateSearchQuery,
                                hintText: 'Search burgers, glazes, ingredients...',
                              ),
                            ),
                            const SizedBox(height: 12.0),

                            // Continuous Marquee Ticker
                            MarqueeWidget(
                              text: 'SMASHED • FRESH • BOLD • 450 KCAL • ZERO GUILT • CRUST CARAMELIZED • ',
                              height: 38.0,
                              speedMultiplier: 0.8,
                              backgroundColor: AppColors.surface,
                              style: AppTypography.caption(
                                fontSize: 13.0,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20.0),

                            // Featured slider
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: AppText(
                                'HOT FEATURED SMASHES',
                                variant: AppTextVariant.goldLabel,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            _buildFeaturedSlider(),

                            const SizedBox(height: 24.0),

                            // Story of Ingredients Card
                            _buildStoryCard(),

                            const SizedBox(height: 24.0),

                            // Categories
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const AppText('EXPLORE MENU', variant: AppTextVariant.goldLabel),
                                  AppText(
                                    '(${controller.filteredBurgers.length} Items)',
                                    variant: AppTextVariant.caption,
                                    color: AppColors.grey,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            _buildCategoriesBar(),

                            const SizedBox(height: 16.0),

                            // Paginated List
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Obx(() {
                                final items = controller.visibleBurgers;
                                if (items.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                      child: AppText(
                                        'No items match search/category.',
                                        variant: AppTextVariant.body,
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final burger = items[index];
                                        return BurgerCard(
                                          burger: burger,
                                          onTap: () => Get.toNamed(AppRoutes.details, arguments: burger),
                                        );
                                      },
                                    ),
                                    if (controller.isLazyLoading.value)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        child: Center(
                                          child: CircularProgressIndicator(color: AppColors.gold),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ),

                            const SizedBox(height: 24.0),

                            // Branches Locator Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: AppText(
                                'LOCATE OUR KITCHENS',
                                variant: AppTextVariant.goldLabel,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            _buildBranchesSection(),
                            const SizedBox(height: 40.0),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFeaturedSlider() {
    return SizedBox(
      height: 140,
      child: Obx(() {
        final list = controller.featuredList;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final burger = list[index];
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.details, arguments: burger),
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        top: -10,
                        bottom: -10,
                        width: 130,
                        child: Opacity(
                          opacity: 0.85,
                          child: Image.network(
                            burger.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surface,
                                AppColors.surface.withOpacity(0.95),
                                Colors.transparent
                              ],
                              stops: const [0.55, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              burger.name.toUpperCase(),
                              variant: AppTextVariant.subtitleMedium,
                              color: AppColors.white,
                            ),
                            const SizedBox(height: 4.0),
                            AppText(
                              'PKR ${burger.price.toInt()}',
                              variant: AppTextVariant.h2,
                              color: AppColors.gold,
                            ),
                            const SizedBox(height: 6.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border, width: 1.0),
                              ),
                              child: AppText(
                                '${burger.calories} kcal',
                                variant: AppTextVariant.caption,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStoryCard() {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'THE MUSTAV WAY',
            variant: AppTextVariant.h2,
            color: AppColors.gold,
          ),
          const SizedBox(height: 8.0),
          AppText(
            'Smashed hot on the flat top, our organic prime beef patties lock in ultimate juiciness under a caramelized crust. No guilt, no filler, only pure craft flavor.',
            variant: AppTextVariant.body,
            color: AppColors.grey.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar() {
    final categories = [
      {'id': 'all', 'label': 'ALL'},
      {'id': 'smashed', 'label': 'SMASHED'},
      {'id': 'sides', 'label': 'SIDES'},
      {'id': 'drinks', 'label': 'DRINKS'},
    ];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat['id'];
            return CategoryChip(
              label: cat['label']!,
              isSelected: isSelected,
              onTap: () => controller.changeCategory(cat['id']!),
            );
          });
        },
      ),
    );
  }

  Widget _buildBranchesSection() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        final list = controller.branches;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final branch = list[index];
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.map, arguments: branch),
              child: Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      branch.name.replaceAll(' Flagship Kitchen', '').replaceAll(' Capital Hub', '').toUpperCase(),
                      variant: AppTextVariant.subtitleMedium,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 4.0),
                    AppText(
                      branch.openingHours,
                      variant: AppTextVariant.caption,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 2.0),
                    const AppText(
                      'TAP TO FIND ON MAP',
                      variant: AppTextVariant.caption,
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          backgroundColor: AppColors.surface,
          title: Text(
            'LOGOUT?',
            style: AppTypography.headingBold(fontSize: 22.0, color: AppColors.gold),
          ),
          content: Text(
            'Are you sure you want to exit your session?',
            style: AppTypography.bodyText(fontSize: 15.0, color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: AppTypography.goldLabel(fontSize: 14.0).copyWith(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                controller.logout();
              },
              child: Text(
                'LOGOUT',
                style: AppTypography.goldLabel(fontSize: 14.0).copyWith(color: AppColors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
