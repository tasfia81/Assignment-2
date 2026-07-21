import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../models/menu_item_model.dart';
import 'app_image.dart';
import 'price_widget.dart';

class BurgerCard extends StatelessWidget {
  final MenuItemModel burger;
  final VoidCallback onTap;

  const BurgerCard({
    super.key,
    required this.burger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Header with dynamic badges
              Stack(
                children: [
                  AppImage(
                    imageUrl: burger.imageUrl,
                    height: 190,
                    width: double.infinity,
                  ),
                  
                  // Top Right: Calories Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold, width: 1.0),
                      ),
                      child: Text(
                        '🔥 ${burger.calories} kcal',
                        style: AppTypography.caption(
                          fontSize: 11.0,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Top Left: Patty Type Badge
                  if (burger.pattyType != 'None')
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1.0),
                        ),
                        child: Text(
                          '🥩 ${burger.pattyType.toUpperCase()}',
                          style: AppTypography.caption(
                            fontSize: 10.0,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            burger.name,
                            style: AppTypography.subtitleMedium(
                              fontSize: 18.0,
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PriceWidget(
                          price: burger.price,
                          fontSize: 18.0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    
                    // Description
                    Text(
                      burger.description,
                      style: AppTypography.bodyText(
                        fontSize: 13.0,
                        color: AppColors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12.0),
                    
                    const Divider(color: AppColors.border, thickness: 1.0),
                    const SizedBox(height: 8.0),
                    
                    // Prep Time, Protein, Spice Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Prep Time
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text(
                              burger.prepTime,
                              style: AppTypography.caption(fontSize: 12.0, color: AppColors.white),
                            ),
                          ],
                        ),
                        
                        // Protein
                        Row(
                          children: [
                            const Icon(Icons.fitness_center_outlined, size: 16, color: AppColors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${burger.protein.toInt()}g Protein',
                              style: AppTypography.caption(fontSize: 12.0, color: AppColors.white),
                            ),
                          ],
                        ),
                        
                        // Spice Level
                        if (burger.spiceLevel != 'None')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.gold, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Text('🌶️', style: TextStyle(fontSize: 8)),
                                const SizedBox(width: 2),
                                Text(
                                  burger.spiceLevel.toUpperCase(),
                                  style: AppTypography.caption(
                                    fontSize: 9.0,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            'Mild Spice',
                            style: AppTypography.caption(fontSize: 12.0, color: AppColors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
