import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/features/auth/controllers/profile_controller.dart';
import 'package:del_pick/core/widgets/custom_button.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  ProfileController get _profileController => Get.find<ProfileController>();
  AuthController get _authController => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final user = _authController.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await _profileController.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Obx(
        () => _profileController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Avatar Section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.1),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                              ),
                              child: _authController.userAvatar != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _authController.userAvatar!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          _getRoleIcon(
                                              _authController.userRole),
                                          size: 60,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      _getRoleIcon(_authController.userRole),
                                      size: 60,
                                      color: AppColors.primary,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: AppColors.textOnPrimary,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement image picker
                                    Get.snackbar(
                                      'Info',
                                      'Image upload feature coming soon',
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXXL),

                      // Form Fields
                      Text(
                        'Personal Information',
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: AppDimensions.spacingLG),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length <
                              AppConstants.minNameLength) {
                            return 'Name must be at least ${AppConstants.minNameLength} characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingLG),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingLG),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(AppConstants.phoneRegex)
                                .hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingXXL),

                      // Update Button
                      CustomButton.primary(
                        text: 'Update Profile',
                        onPressed: _handleUpdateProfile,
                        isLoading: _profileController.isLoading,
                        isExpanded: true,
                      ),
                      const SizedBox(height: AppDimensions.spacingLG),

                      // Cancel Button
                      CustomButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        type: ButtonType.outlined,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return Icons.person;
      case AppConstants.roleDriver:
        return Icons.delivery_dining;
      case AppConstants.roleStore:
        return Icons.store;
      default:
        return Icons.person;
    }
  }
}
