// presentation/auth/login/login_screen.dart
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/main.dart';
import 'package:app_vendor/presentation/auth/forgot_password/forgot_password_screen.dart';
import 'package:app_vendor/presentation/auth/register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../services/api_client.dart';

Future<bool> checkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

const Color primaryPink = Color(0xFFE51742);
const Color inputFill = Color(0xFFF4F4F4);
const Color lightBorder = Color(0xFFDDDDDD);
const Color greyText = Color(0xFF777777);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: const LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _cleanError(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring(11) : s;
  }

  // presentation/auth/login/login_screen.dart - Update the login method

  // presentation/auth/login/login_screen.dart - SIMPLIFIED

  Future<void> _onLoginPressed() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showMessage("Please fix the errors and try again.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Login first
      await ApiClient().loginCustomer(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 2. Simple check - if login worked, user is valid
      _showMessage("Login successful!", isError: false);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );

    } catch (e) {
      _showMessage("Login failed: ${_cleanError(e)}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    _showMessage('Google Sign-In is coming soon! Please use email login.', isError: false);
  }

  Future<void> _signInWithFacebook() async {
    _showMessage('Facebook Sign-In is coming soon! Please use email login.', isError: false);
  }

  Future<void> _signInWithInstagram() async {
    _showMessage('Instagram Sign-In is coming soon! Please use email login.', isError: false);
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    // simple email check
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    if ((v ?? '').isEmpty) return 'Password is required';
    if ((v ?? '').length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            t?.welcomeBack ?? "Welcome Back",
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 36),

          // Email
          _CustomInput(
            controller: _emailController,
            hintText: t?.usernameOrEmail ?? "Username or Email",
            icon: Icons.person_outline,
            validator: _emailValidator,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          // Password
          _CustomInput(
            controller: _passwordController,
            hintText: t?.password ?? "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: _passwordValidator,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onLoginPressed(),
          ),

          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryPink,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t?.forgotPwd ?? "Forgot Password?",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text(
                t?.login ?? "Login",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 40),
          Row(
            children: [
              const Expanded(child: Divider(color: lightBorder)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  t?.continueWith ?? "Continue with",
                  style: const TextStyle(color: greyText, fontSize: 14),
                ),
              ),
              const Expanded(child: Divider(color: lightBorder)),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialButton(icon: 'assets/google.png', onTap: _signInWithGoogle),
              const SizedBox(width: 20),
              SocialButton(icon: 'assets/instagram.png', onTap: _signInWithInstagram),
              const SizedBox(width: 20),
              SocialButton(icon: 'assets/facebook.png', onTap: _signInWithFacebook),
            ],
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t?.createAnAccountLogin ?? "Don't have an account?",
                style: const TextStyle(color: greyText, fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: primaryPink, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CustomInput extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const _CustomInput({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputFill,
        hintText: hintText,
        hintStyle: const TextStyle(color: greyText, fontSize: 16),
        prefixIcon: Icon(icon, color: greyText),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: greyText),
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
    );
  }
}

class SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;

  const SocialButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryPink, width: 1.5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Image.asset(icon, fit: BoxFit.contain),
      ),
    );
  }
}