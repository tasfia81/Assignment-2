import 'dart:convert';
import 'package:hive/hive.dart';
import '../core/values/constants.dart';
import '../models/user_model.dart';

/// Abstract contract for user authentication and profile management.
abstract class AuthRepository {
  /// Authenticates a user with email and password credentials.
  Future<UserModel?> login(String email, String password);

  /// Registers a new user account with profile details and default address.
  Future<UserModel?> signUp(String name, String email, String phone, String address);

  /// Reads current persisted user session from Hive storage (`userBox`).
  Future<UserModel?> getCurrentUser();

  /// Logs out current user by clearing session tokens and user data.
  Future<void> logout();

  /// Updates delivery address text and GPS coordinates in user profile.
  Future<bool> updateAddress(String address, double lat, double lng);
}

/// Production implementation of [AuthRepository] persisting sessions in Hive local storage.
class AuthRepositoryImpl implements AuthRepository {
  final Box _userBox;

  AuthRepositoryImpl(this._userBox);

  /// Authenticates user and saves session tokens locally.
  @override
  Future<UserModel?> login(String email, String password) async {
    // Simulate network authentication request latency
    await Future.delayed(const Duration(milliseconds: 800));

    // Construct mock user profile based on email address
    final name = email.split('@')[0];
    final user = UserModel(
      id: 'usr_mock_123',
      name: name[0].toUpperCase() + name.substring(1),
      email: email,
      phone: '+92 300 1234567',
      address: 'DHA Phase 6, Lahore, Pakistan',
      latitude: AppConstants.lahoreLat,
      longitude: AppConstants.lahoreLng,
    );

    await _saveUserSession(user);
    return user;
  }

  /// Registers a new user profile and persists session data.
  @override
  Future<UserModel?> signUp(String name, String email, String phone, String address) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final user = UserModel(
      id: 'usr_mock_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      address: address,
      latitude: AppConstants.lahoreLat,
      longitude: AppConstants.lahoreLng,
    );

    await _saveUserSession(user);
    return user;
  }

  /// Deserializes current user profile from Hive storage.
  @override
  Future<UserModel?> getCurrentUser() async {
    final String? userJson = _userBox.get(AppConstants.keyUserData) as String?;
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Clears stored user session and authentication token from disk.
  @override
  Future<void> logout() async {
    await _userBox.delete(AppConstants.keyUserData);
    await _userBox.delete(AppConstants.keyUserToken);
  }

  /// Updates profile address and GPS coordinates in Hive storage.
  @override
  Future<bool> updateAddress(String address, double lat, double lng) async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        address: address,
        latitude: lat,
        longitude: lng,
      );
      await _saveUserSession(updatedUser);
      return true;
    }
    return false;
  }

  /// Serializes user profile and updates session token in Hive.
  Future<void> _saveUserSession(UserModel user) async {
    await _userBox.put(AppConstants.keyUserData, jsonEncode(user.toJson()));
    await _userBox.put(AppConstants.keyUserToken, 'mock_jwt_token_mustav_123');
  }
}
