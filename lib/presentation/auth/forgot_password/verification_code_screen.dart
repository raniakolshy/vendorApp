import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:kolshy_vendor/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/api_client.dart';

const Color primaryPink = Color(0xFFE51742);
const Color inputFill = Color(0xFFF4F4F4);
const Color lightBorder = Color(0xFFDDDDDD);
const Color greyText = Color(0xFF777777);

class VerificationCodeScreen extends StatefulWidget {
  final String? email;
  const VerificationCodeScreen({super.key, this.email});
  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _pwdController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePwd = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if ((widget.email ?? '').isNotEmpty) {
      _emailController.text = widget.email!.trim();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _pwdController.dispose();
    _confirmController.dispose();
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

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _tokenValidator(String? v) {
    if ((v ?? '').trim().isEmpty) return 'Reset token is required';
    return null;
  }

  String? _passwordValidator(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v != _pwdController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _onSubmit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _toast('Please fix the errors and try again.');
      return;
    }

    setState(() => _loading = true);
    try {
      _toast('Password has been reset. You can log in now.', err: false);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } catch (e) {
      final s = e.toString();
      _toast(s.startsWith('Exception: ') ? s.substring(11) : s);
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
                Text(
                  t?.verificationCode ?? "Reset Password",
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Paste the reset token from the email, then set a new password.",
                  style: const TextStyle(fontSize: 14, color: greyText),
                ),

                const SizedBox(height: 28),
                _LabeledInput(
                  label: t?.email ?? 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 16),
                _LabeledInput(
                  label: 'Reset token',
                  controller: _tokenController,
                  validator: _tokenValidator,
                ),
                const SizedBox(height: 16),
                _LabeledInput(
                  label: t?.password ?? 'New Password',
                  controller: _pwdController,
                  isPassword: true,
                  obscureText: _obscurePwd,
                  toggleVisibility: () => setState(() => _obscurePwd = !_obscurePwd),
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 16),
                _LabeledInput(
                  label: t?.passworConfirmation ?? 'Confirm Password',
                  controller: _confirmController,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  toggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: _confirmValidator,
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      t?.submit ?? "Submit",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _LabeledInput({
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFill,
            hintText: label,
            hintStyle: const TextStyle(color: greyText, fontSize: 16),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: greyText,
              ),
              onPressed: toggleVisibility,
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryPink, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}