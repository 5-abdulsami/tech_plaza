import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';

class CnicUploadView extends GetView<AuthController> {
  const CnicUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final shopNameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    final phoneController = TextEditingController();

    final selectedCnicImage = Rx<XFile?>(null);
    final selectedLogoImage = Rx<XFile?>(null);
    final selectedPlaza = 'Dubai Plaza'.obs;

    final ImagePicker picker = ImagePicker();

    final plazas = [
      'Dubai Plaza',
      'Singapore Plaza',
      'Imperial Market',
      'Tech City',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('upload_cnic'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Shop Setup',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Complete your shop registration by providing the required information',
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 32),

              // CNIC Upload
              Text(
                'CNIC Document *',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      selectedCnicImage.value = image;
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Get.theme.colorScheme.outline,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedCnicImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(selectedCnicImage.value!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color: Get.theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Take CNIC Photo',
                                style: TextStyle(
                                  color: Get.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Shop Information
              Text(
                'Shop Information',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Shop Name
              TextFormField(
                controller: shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name *',
                  hintText: 'Enter your shop name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shop name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Plaza Selection
              DropdownButtonFormField<String>(
                value: selectedPlaza.value,
                decoration: const InputDecoration(
                  labelText: 'Plaza Location *',
                ),
                items: plazas.map((plaza) {
                  return DropdownMenuItem(value: plaza, child: Text(plaza));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedPlaza.value = value;
                  }
                },
              ),

              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Shop Address *',
                  hintText: 'Enter complete address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shop address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Shop Phone',
                  hintText: 'Enter shop contact number',
                ),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Shop Description *',
                  hintText: 'Describe your shop and products',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shop description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Logo Upload (Optional)
              Text(
                'Shop Logo (Optional)',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      selectedLogoImage.value = image;
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Get.theme.colorScheme.outline,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedLogoImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(selectedLogoImage.value!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: Get.theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Logo',
                                style: TextStyle(
                                  color: Get.theme.colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () => _handleSubmit(
                            formKey,
                            selectedCnicImage.value,
                            shopNameController.text,
                            selectedPlaza.value,
                            addressController.text,
                            descriptionController.text,
                            phoneController.text,
                            selectedLogoImage.value,
                          ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Complete Registration'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(
    GlobalKey<FormState> formKey,
    XFile? cnicImage,
    String shopName,
    String plaza,
    String address,
    String description,
    String phone,
    XFile? logoImage,
  ) {
    if (formKey.currentState!.validate()) {
      if (cnicImage == null) {
        Get.snackbar(
          'error'.tr,
          'Please upload CNIC photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }

      controller.uploadCnicAndCreateShop(
        cnicImagePath: cnicImage.path,
        shopName: shopName,
        plazaId: plaza, // In real app, this would be plaza ID
        address: address,
        description: description,
        phone: phone.isNotEmpty ? phone : null,
        logoPath: logoImage?.path,
      );
    }
  }
}
