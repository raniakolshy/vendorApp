// screens/register/register_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/main.dart';
import '../../../services/api_client.dart';
import '../../../services/magento_api.dart';
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
  final _first = TextEditingController();
  final _last  = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass  = TextEditingController();
  final _confirm = TextEditingController();

  final _api = ApiClient();

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

  Future<void> _onRegister() async {
    if (_loading) return;
    if (!_isChecked) { _toast('You must accept the public offer'); return; }
    if (_pass.text != _confirm.text) { _toast('Passwords do not match'); return; }

    setState(() => _loading = true);
    try {
      print('Creating customer with: ${_email.text.trim()}');

      final customerResponse = await _api.createCustomer(
        firstname: _first.text.trim(),
        lastname: _last.text.trim(),
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      print('Customer creation response: $customerResponse');

      print('Attempting to login with new credentials');
      final token = await _api.loginCustomer(_email.text.trim(), _pass.text.trim());

      print('Login successful, token received');
      _toast('Account created & logged in!', err: false);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
    } catch (e) {
      print('Registration error: $e');

      if (e.toString().contains('already exists')) {
        _toast('Email address is already registered');
      } else {
        _toast('Registration failed: ${e.toString()}');
      }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(t?.createSimple ?? 'Create',
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black87)),
              Text(t?.anAccount ?? 'an account',
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 36),

              _Input(controller: _first, hintText: t?.firstName ?? 'First name', icon: Icons.person_outline),
              const SizedBox(height: 20),
              _Input(controller: _last, hintText: t?.lastName ?? 'Last name', icon: Icons.person_outline),
              const SizedBox(height: 20),
              _Input(controller: _email, hintText: t?.email ?? 'Email',
                  icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _Input(controller: _phone, hintText: t?.phone ?? 'Phone',
                  icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),

              _Input(
                controller: _pass, hintText: t?.password ?? 'Password', icon: Icons.lock_outline,
                isPassword: true, obscureText: _obscurePass,
                toggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
              ),
              const SizedBox(height: 20),
              _Input(
                controller: _confirm, hintText: t?.passworConfirmation ?? 'Password confirmation',
                icon: Icons.lock_outline, isPassword: true, obscureText: _obscureConfirm,
                toggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
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
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t?.create ?? 'Create',
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t?.alreadyHaveAnAccount ?? 'Already have an account?',
                      style: const TextStyle(color: greyText, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Text('Login',
                          style: TextStyle(color: primaryPink, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
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
              width: 24, height: 24,
              child: Checkbox(
                value: value, onChanged: onChanged,
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

class _Input extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final TextInputType keyboardType;

  const _Input({
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        filled: true, fillColor: inputFill,
        hintText: hintText, hintStyle: const TextStyle(color: greyText, fontSize: 16),
        prefixIcon: Icon(icon, color: greyText),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: greyText),
          onPressed: toggleVisibility,
        ) : null,
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
    );
  }
}