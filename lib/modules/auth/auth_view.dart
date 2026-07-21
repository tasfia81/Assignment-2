import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text.dart';
import '../../widgets/offline_banner.dart';
import 'auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Obx(() => Column(
            children: [
              // Offline status warning banner
              if (connectivityService.isOffline.value) const OfflineBanner(),
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32.0),
                        // Golden circle burger emoji mascot
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.15),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: const Text(
                              '🍔',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        
                        // Header
                        Center(
                          child: AppText(
                            'MUSTAV',
                            variant: AppTextVariant.h1,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Center(
                          child: AppText(
                            'PREMIUM ARTISAN EXPERIENCE',
                            variant: AppTextVariant.caption,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 36.0),
                        
                        // Auth Card
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                controller.isLoginMode.value ? 'WELCOME BACK' : 'CREATE ACCOUNT',
                                textAlign: TextAlign.center,
                                style: AppTypography.headingBold(fontSize: 20.0, color: AppColors.white),
                              ),
                              const SizedBox(height: 24.0),
                              if (!controller.isLoginMode.value) ...[
                                _buildTextField(
                                  controller: controller.nameController,
                                  hint: 'Full Name',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 16.0),
                              ],
                              _buildTextField(
                                controller: controller.emailController,
                                  hint: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16.0),
                                if (!controller.isLoginMode.value) ...[
                                  _buildTextField(
                                    controller: controller.phoneController,
                                    hint: 'Phone Number',
                                    icon: Icons.phone_android_outlined,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 16.0),
                                  _buildTextField(
                                    controller: controller.addressController,
                                    hint: 'Delivery Address',
                                    icon: Icons.map_outlined,
                                  ),
                                  const SizedBox(height: 16.0),
                                ],
                                _buildTextField(
                                  controller: controller.passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                ),
                                const SizedBox(height: 28.0),
                                AppButton(
                                  text: controller.isLoginMode.value ? 'ENTER KITCHEN' : 'CREATE ACCOUNT',
                                  isLoading: controller.isLoading.value,
                                  onPressed: controller.submit,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24.0),
                        // Toggle Auth Type Action
                        GestureDetector(
                          onTap: controller.toggleMode,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTypography.bodyText(fontSize: 14.0, color: AppColors.grey),
                              children: [
                                TextSpan(
                                  text: controller.isLoginMode.value
                                      ? "Don't have an account? "
                                      : "Already have an account? ",
                                ),
                                TextSpan(
                                  text: controller.isLoginMode.value ? 'SIGN UP NOW' : 'LOG IN',
                                  style: AppTypography.goldLabel(fontSize: 14.0).copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTypography.bodyText(color: AppColors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.grey),
          hintText: hint,
          hintStyle: AppTypography.bodyText(color: AppColors.grey.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
      ),
    );
  }
}
