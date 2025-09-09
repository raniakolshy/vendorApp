// presentation/auth/register/register_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/main.dart';
import '../../../services/api_client.dart';
import '../login/login_screen.dart';

const Color primaryPink = Color(0xFFE51742);
const Color inputFill = Color(0xFFF4F4F4);
const Color lightBorder = Color(0xFFDDDDDD);
const Color greyText = Color(0xFF777777);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _shopUrl = TextEditingController();

  bool _isChecked = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    _confirm.dispose();
    _shopUrl.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool err = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: err ? Colors.red : primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Validation methods
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 8) return 'Enter a valid phone number';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value != _pass.text) return 'Passwords do not match';
    return null;
  }

  String? _shopUrlValidator(String? value) {
    if (value == null || value.isEmpty) return 'Shop URL is required';
    if (value.contains(' ')) return 'Shop URL cannot contain spaces';
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
      return 'Use only lowercase letters, numbers, and hyphens';
    }
    return null;
  }

  Future<void> _onRegister() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _toast('Please fix the errors and try again.');
      return;
    }

    if (!_isChecked) {
      _toast('You must accept the terms and conditions');
      return;
    }

    setState(() => _loading = true);
    try {
      await VendorApiClient().registerVendor(
        _email.text.trim(),
        _first.text.trim(),
        _last.text.trim(),
        _pass.text.trim(),
        _shopUrl.text.trim(),
        _phone.text.trim(),
      );

      // Auto-login
      await VendorApiClient().loginVendor(
        _email.text.trim(),
        _pass.text.trim(),
      );

      _toast('Account created successfully!', err: false);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      _toast('Registration failed: $errorMessage');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(t?.createSimple ?? 'Create',
                    style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black87)),
                Text(t?.anAccount ?? 'an account',
                    style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black87)),
                const SizedBox(height: 36),

                // First Name
                TextFormField(
                  controller: _first,
                  validator: (value) => _requiredValidator(value, 'First name'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: t?.firstName ?? 'First name',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.person_outline, color: greyText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Last Name
                TextFormField(
                  controller: _last,
                  validator: (value) => _requiredValidator(value, 'Last name'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: t?.lastName ?? 'Last name',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.person_outline, color: greyText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _email,
                  validator: _emailValidator,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: t?.email ?? 'Email',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.email_outlined, color: greyText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone
                TextFormField(
                  controller: _phone,
                  validator: _phoneValidator,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: t?.phone ?? 'Phone',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.phone_outlined, color: greyText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Shop URL
                TextFormField(
                  controller: _shopUrl,
                  validator: _shopUrlValidator,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: 'Shop URL (unique, e.g. my-store)',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.storefront_outlined, color: greyText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _pass,
                  validator: _passwordValidator,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: t?.password ?? 'Password',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.lock_outline, color: greyText),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: greyText),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: _confirm,
                  validator: _confirmPasswordValidator,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    hintText: t?.passworConfirmation ?? 'Password confirmation',
                    hintStyle: const TextStyle(color: greyText, fontSize: 16),
                    prefixIcon: const Icon(Icons.lock_outline, color: greyText),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: greyText),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: lightBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryPink, width: 2)),
                  ),
                ),

                const SizedBox(height: 16),
                _checkRow(
                  value: _isChecked,
                  title: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(color: Colors.black87),
                      children: [
                        TextSpan(text: '${t?.byClickingThe ?? 'By clicking the'} '),
                        TextSpan(text: t?.signUp ?? 'Sign up',
                            style: GoogleFonts.poppins(color: primaryPink, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' ${t?.publicOffer ?? 'you accept the public offer'}'),
                      ],
                    ),
                  ),
                  onChanged: (v) => setState(() => _isChecked = v ?? false),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(t?.create ?? 'Create', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t?.alreadyHaveAnAccount ?? 'Already have an account?', style: const TextStyle(color: greyText, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Text('Login', style: TextStyle(color: primaryPink, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkRow({required Widget title, required bool value, required Function(bool?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: lightBorder, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: title),
          ],
        ),
      ),
    );
  }
}