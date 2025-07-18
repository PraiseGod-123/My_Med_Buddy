// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_spinner.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _allergyController = TextEditingController();

  List<String> _allergies = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone;
    _ageController.text = widget.user.age.toString();
    _conditionController.text = widget.user.condition;
    _emergencyContactController.text = widget.user.emergencyContact;
    _allergies = List.from(widget.user.allergies);

    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _conditionController.addListener(_onFieldChanged);
    _emergencyContactController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _emergencyContactController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => _handleBackButton(),
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading
                    ? AppColors.textSecondary
                    : AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImageSection(),
                const SizedBox(height: 32),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildMedicalInfoSection(),
                const SizedBox(height: 24),
                _buildAllergiesSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: LoadingSpinner()),
          ),
      ],
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.primaryColor,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          validator: Validators.validateName,
          prefixIcon: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ageController,
          label: 'Age',
          hint: 'Enter your age',
          keyboardType: TextInputType.number,
          validator: Validators.validateAge,
          prefixIcon: const Icon(Icons.cake_outlined),
        ),
      ],
    );
  }

  Widget _buildMedicalInfoSection() {
    return _buildSection(
      title: 'Medical Information',
      icon: Icons.medical_services,
      children: [
        CustomTextField(
          controller: _conditionController,
          label: 'Medical Condition',
          hint: 'Enter any medical conditions (optional)',
          maxLines: 2,
          prefixIcon: const Icon(Icons.local_hospital_outlined),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emergencyContactController,
          label: 'Emergency Contact',
          hint: 'Enter emergency contact name or number',
          validator: (value) =>
              Validators.validateRequired(value, 'Emergency Contact'),
          prefixIcon: const Icon(Icons.emergency_outlined),
        ),
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return _buildSection(
      title: 'Allergies',
      icon: Icons.warning,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _allergyController,
                label: 'Add Allergy',
                hint: 'Enter an allergy',
                prefixIcon: const Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _addAllergy,
              icon: const Icon(
                Icons.add_circle,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
          ],
        ),
        if (_allergies.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies
                .map((allergy) => _buildAllergyChip(allergy))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAllergyChip(String allergy) {
    return Chip(
      label: Text(
        allergy,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.errorColor,
        ),
      ),
      backgroundColor: AppColors.errorColor.withOpacity(0.1),
      side: BorderSide(color: AppColors.errorColor.withOpacity(0.3)),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
        color: AppColors.errorColor,
      ),
      onDeleted: () => _removeAllergy(allergy),
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: 'Save Changes',
      onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
      isLoading: _isLoading,
    );
  }

  // Methods
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _chooseFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.errorColor),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _takePhoto() {
    // TODO: Implement camera functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _chooseFromGallery() {
    // TODO: Implement gallery functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removePhoto() {
    // TODO: Implement photo removal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _addAllergy() {
    final allergy = _allergyController.text.trim();
    if (allergy.isNotEmpty && !_allergies.contains(allergy)) {
      setState(() {
        _allergies.add(allergy);
        _allergyController.clear();
        _hasChanges = true;
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
      _hasChanges = true;
    });
  }

  void _handleBackButton() {
    if (_hasChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save them before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
            },
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _saveProfile(); // Save and then close
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = UserModel(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        condition: _conditionController.text.trim(),
        medicationReminders: widget.user.medicationReminders,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        allergies: _allergies,
        emergencyContact: _emergencyContactController.text.trim(),
      );

      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).updateUser(updatedUser);

      if (mounted) {
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
