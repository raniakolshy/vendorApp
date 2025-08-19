import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;
  String? _country;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // General Information Card
              _buildSectionCard(
                title: 'General Information',
                children: [
                  _buildInputField(
                    controller: _firstNameController,
                    label: 'First Name',
                    placeholder: 'Input your first name',
                    helpText: "Enter the user's first name.",
                  ),
                  _buildInputField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    placeholder: 'Input your last name',
                    helpText: "Enter the user's last name.",
                  ),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    placeholder: 'Ex: example@mail.com',
                    helpText: "The user's primary email address.",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    placeholder: 'e.g., +20 123 456 7890',
                    helpText: "Contact number for notifications or two-factor authentication.",
                    keyboardType: TextInputType.phone,
                  ),
                  _buildDropdownField(
                    value: _gender,
                    label: 'Gender',
                    hint: 'Select gender',
                    helpText: "Select the user's gender.",
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address & Location Card
              _buildSectionCard(
                title: 'Address & Location',
                children: [
                  _buildInputField(
                    controller: _streetController,
                    label: 'Street Address',
                    placeholder: 'Ex: 123 Main St',
                    helpText: "Enter the user's full street address.",
                  ),
                  _buildInputField(
                    controller: _cityController,
                    label: 'City',
                    placeholder: 'Ex: New York',
                    helpText: "The city where the user resides.",
                  ),
                  _buildInputField(
                    controller: _stateController,
                    label: 'State / Province',
                    placeholder: 'Ex: NY',
                    helpText: "The user's state or province.",
                  ),
                  _buildInputField(
                    controller: _postalController,
                    label: 'Postal Code',
                    placeholder: 'Ex: 10001',
                    helpText: "The postal or ZIP code.",
                    keyboardType: TextInputType.number,
                  ),
                  _buildDropdownField(
                    value: _country,
                    label: 'Country',
                    hint: 'Select country',
                    helpText: "The user's country of residence.",
                    items: const ['United States', 'Canada', 'United Kingdom', 'Egypt', 'Germany'],
                    onChanged: (value) {
                      setState(() {
                        _country = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password & Security Card
              _buildSectionCard(
                title: 'Password & Security',
                children: [
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    placeholder: 'Enter your current password',
                    helpText: "Required to confirm changes to your profile.",
                  ),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    placeholder: 'Enter a new password',
                    helpText: "Leave blank to keep your current password.",
                  ),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    placeholder: 'Re-enter your new password',
                    helpText: "Must match the new password.",
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile Image Card
              _buildSectionCard(
                title: 'Profile Image',
                children: [
                  const Text(
                    "Upload a clear, high-resolution profile picture.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF888888),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Color(0xFF888888)),
                        SizedBox(height: 8),
                        Text(
                          'Click or drop image',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Space for footer
            ],
          ),
        ),
      ),

      // Footer with action buttons
      bottomSheet: Container(
        color: const Color(0xFFF3F3F4),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Delete Account Button
            IconButton(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete, color: Colors.red),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),

            // Cancel and Save buttons
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required String helpText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 16, color: Color(0xFF888888)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF888888)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEDEEEF)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          keyboardType: keyboardType,
        ),
        const SizedBox(height: 4),
        Text(
          helpText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required String helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 16, color: Color(0xFF888888)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF888888)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEDEEEF)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helpText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required String helpText,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 16, color: Color(0xFF888888)),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF888888)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEDEEEF)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
        Text(
          helpText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Save profile logic here
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Navigate back
                // Add account deletion logic here
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}