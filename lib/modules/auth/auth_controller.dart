import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repository/auth_repository.dart';
import '../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isLoginMode = true.obs;
  final isLoading = false.obs;

  // Controllers for text fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    clearFields();
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    passwordController.clear();
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    isLoading.value = true;
    try {
      if (isLoginMode.value) {
        final user = await _authRepository.login(email, password);
        if (user != null) {
          Get.snackbar('Success', 'Welcome back, ${user.name}!', snackPosition: SnackPosition.BOTTOM);
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        final name = nameController.text.trim();
        final phone = phoneController.text.trim();
        final address = addressController.text.trim();

        if (name.isEmpty || phone.isEmpty || address.isEmpty) {
          Get.snackbar('Error', 'All fields are required for sign up');
          isLoading.value = false;
          return;
        }

        final user = await _authRepository.signUp(name, email, phone, address);
        if (user != null) {
          Get.snackbar('Success', 'Welcome to MUSTAV, ${user.name}!', snackPosition: SnackPosition.BOTTOM);
          Get.offAllNamed(AppRoutes.home);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Authentication failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
