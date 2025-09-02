import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../login/login_screen.dart';

// Social sign-up
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

Future<bool> _hasInternet() async =>
    (await Connectivity().checkConnectivity()) != ConnectivityResult.none;

const Color primaryPink = Color(0xFFE51742);
const Color inputFill = Color(0xFFF4F4F4);
const Color lightBorder = Color(0xFFDDDDDD);
const Color greyText = Color(0xFF777777);

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '701685580916-4hv0pfq73jksr1ga8pp22p8clt80uioe.apps.googleusercontent.com',
  scopes: ['email'],
);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _confirmController   = TextEditingController();

  bool _isChecked = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading = false;

  // If your Magento needs these, set them here (or pass from env/config)
  final int? _websiteId = 1; // set to null if not needed
  final int? _storeId   = 1; // set to null if not needed

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _cleanErr(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring(11) : s;
  }

  // ---------- Validators ----------
  String? _nameValidator(String? v, String label) {
    final val = (v ?? '').trim();
    if (val.isEmpty) return '$label is required';
    if (val.length < 2) return '$label must be at least 2 characters';
    return null;
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    // add more rules if Magento enforces them (digits, uppercase, etc.)
    return null;
  }

  String? _confirmValidator(String? v) {
    if ((v ?? '').isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _onRegister() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_isChecked) {
      _toast('You must accept the public offer', error: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      _toast('Please fix the errors and try again.', error: true);
      return;
    }
    if (!await _hasInternet()) {
      _toast('No internet connection.', error: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().registerCustomer(
        email: _emailController.text.trim(),
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        websiteId: _websiteId,
        storeId: _storeId,
      );

      _toast('Account created successfully!', error: false);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
    } catch (e) {
      _toast('Registration failed: ${_cleanErr(e)}', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- Social sign-up (unchanged logic, with small guards) ----------
  Future<void> _signUpWithGoogle() async {
    if (_isLoading) return;
    if (!await _hasInternet()) {
      _toast('No internet connection.', error: true);
      return;
    }
    _toast('Initiating Google Sign-Up...', error: false);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _toast('Google Sign-Up cancelled.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken ?? '';

      if ((idToken ?? '').isEmpty) {
        _toast('Google Sign-Up failed: missing ID token.', error: true);
        return;
      }

      final response = await http.post(
        Uri.parse('https://kolshy.ae/sociallogin/social/callback/'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'provider': 'google',
          'idToken': idToken,
          'accessToken': accessToken,
          'email': googleUser.email,
          'displayName': googleUser.displayName ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? token = data['token'];
        if (token != null && token.isNotEmpty) {
          await ApiClient().saveAuthToken(token); // writes to customer_token (with our unified ApiClient)
          _toast('Google Sign-Up successful!', error: false);
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
        } else {
          _toast('Sign-up failed: Token not found in the response.', error: true);
        }
      } else {
        _toast('Backend authentication failed: ${response.body}', error: true);
      }
    } catch (e) {
      _toast('Google Sign-Up failed: ${_cleanErr(e)}', error: true);
    }
  }

  Future<void> _signUpWithFacebook() async {
    if (_isLoading) return;
    if (!await _hasInternet()) {
      _toast('No internet connection.', error: true);
      return;
    }
    _toast('Initiating Facebook Sign-Up...', error: false);
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.success) {
        final at = result.accessToken;
        if (at == null) {
          _toast('Facebook Sign-Up failed: missing access token.', error: true);
          return;
        }

        final response = await http.post(
          Uri.parse('https://kolshy.ae/sociallogin/social/callback/'),
          headers: const {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'provider': 'facebook', 'accessToken': at.token}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String? token = data['token'];
          if (token != null && token.isNotEmpty) {
            await ApiClient().saveAuthToken(token);
            _toast('Facebook Sign-Up successful!', error: false);
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
          } else {
            _toast('Sign-up failed: Token not found in the response.', error: true);
          }
        } else {
          _toast('Backend authentication failed: ${response.body}', error: true);
        }
      } else if (result.status == LoginStatus.cancelled) {
        _toast('Facebook Sign-Up cancelled.');
      } else {
        _toast('Facebook Sign-Up failed: ${result.message}', error: true);
      }
    } catch (e) {
      _toast('Facebook Sign-Up failed: ${_cleanErr(e)}', error: true);
    }
  }

  Future<void> _signUpWithInstagram() async {
    if (_isLoading) return;
    if (!await _hasInternet()) {
      _toast('No internet connection.', error: true);
      return;
    }
    _toast('Initiating Instagram Sign-Up...', error: false);
    try {
      const String instagramAppId = '642270335021538';
      const String redirectUri   = 'https://kolshy.ae/sociallogin/social/callback/instagram.php';
      const String authorizationUrl =
          'https://api.instagram.com/oauth/authorize'
          '?client_id=$instagramAppId'
          '&redirect_uri=$redirectUri'
          '&scope=user_profile,user_media'
          '&response_type=code';

      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl,
        callbackUrlScheme: "https",
      );

      final uri = Uri.parse(result);
      final code  = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (code != null) {
        final response = await http.post(
          Uri.parse('https://kolshy.ae/sociallogin/social/callback/instagram.php'),
          headers: const {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'provider': 'instagram', 'code': code}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String? token = data['token'];
          if (token != null && token.isNotEmpty) {
            await ApiClient().saveAuthToken(token);
            _toast('Instagram Sign-Up successful!', error: false);
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
          } else {
            _toast('Sign-up failed: Token not found in the response.', error: true);
          }
        } else {
          _toast('Backend authentication failed: ${response.body}', error: true);
        }
      } else if (error != null) {
        _toast('Instagram Sign-Up failed: ${uri.queryParameters['error_description'] ?? error}', error: true);
      } else {
        _toast('Instagram Sign-Up cancelled.');
      }
    } catch (e) {
      _toast('Instagram Sign-Up failed: ${_cleanErr(e)}', error: true);
    }
  }

  // ---------- UI ----------
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
                Text(
                  t?.createSimple ?? 'Create',
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                Text(
                  t?.anAccount ?? 'an account',
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                const SizedBox(height: 36),

                _Input(
                  controller: _firstNameController,
                  hintText: t?.firstName ?? 'First name',
                  icon: Icons.person_outline,
                  validator: (v) => _nameValidator(v, 'First name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _Input(
                  controller: _lastNameController,
                  hintText: t?.lastName ?? 'Last name',
                  icon: Icons.person_outline,
                  validator: (v) => _nameValidator(v, 'Last name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _Input(
                  controller: _emailController,
                  hintText: t?.email ?? 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _Input(
                  controller: _phoneController,
                  hintText: t?.phone ?? 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  // phone optional; add your own validator if you need a format check
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _Input(
                  controller: _passwordController,
                  hintText: t?.password ?? 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: _passwordValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _Input(
                  controller: _confirmController,
                  hintText: t?.passworConfirmation ?? 'Password confirmation',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  toggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: _confirmValidator,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onRegister(),
                ),

                const SizedBox(height: 16),
                _buildCheckboxItem(
                  title: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(color: Colors.black87),
                      children: [
                        TextSpan(text: '${t?.byClickingThe ?? 'By clicking the'} '),
                        TextSpan(
                          text: t?.signUp ?? 'Sign up',
                          style: GoogleFonts.poppins(color: primaryPink, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${t?.publicOffer ?? 'you accept the public offer'}'),
                      ],
                    ),
                  ),
                  value: _isChecked,
                  onChanged: (v) => setState(() => _isChecked = v ?? false),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(t?.create ?? 'Create', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 40),
                Row(
                  children: [
                    const Expanded(child: Divider(color: lightBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(t?.continueWith ?? 'Continue with', style: const TextStyle(color: greyText)),
                    ),
                    const Expanded(child: Divider(color: lightBorder)),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(icon: 'assets/google.png', onTap: _signUpWithGoogle),
                    const SizedBox(width: 20),
                    SocialButton(icon: 'assets/instagram.png', onTap: _signUpWithInstagram),
                    const SizedBox(width: 20),
                    SocialButton(icon: 'assets/facebook.png', onTap: _signUpWithFacebook),
                  ],
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t?.alreadyHaveAnAccount ?? 'Already have an account?', style: const TextStyle(color: greyText, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
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

  Widget _buildCheckboxItem({
    required Widget title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
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

class _Input extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const _Input({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
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
