import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login/login_screen.dart';

// Imports for social sign-up
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

// Theme constants
const Color primaryPink = Color(0xFFE51742);
const Color inputFill = Color(0xFFF4F4F4);
const Color lightBorder = Color(0xFFDDDDDD);
const Color greyText = Color(0xFF777777);

// A global instance for Google Sign-In, shared with the login page
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '524516881115-erpl9ot3g239d893kctb06o9dnb16v11.apps.googleusercontent.com',
  serverClientId: '524516881115-erpl9ot3g239d893kctb06o9dnb16v11.apps.googleusercontent.com',
  scopes: ['email'],
);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // UI states
  bool _isChecked = false;
  bool _newsletter = false;
  bool _remoteAssist = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _sellerChoice = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = true}) {
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

  void _onRegister() {
    if (!_isChecked) {
      _showMessage('You must accept the public offer');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }
    _showMessage('Account created successfully!', isError: false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
  }

  // --- Social Sign-Up Methods ---

  Future<void> _signUpWithGoogle() async {
    _showMessage('Initiating Google Sign-Up...', isError: false);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showMessage('Google Sign-Up cancelled.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken ?? '';

      if (idToken == null || idToken.isEmpty) {
        _showMessage('Google Sign-Up failed: missing ID token.');
        return;
      }

      final response = await http.post(
        Uri.parse('https://kolshy.ae/sociallogin/social/callback/'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'provider': 'google',
          'idToken': idToken,
          'accessToken': accessToken,
          'email': googleUser.email,
          'displayName': googleUser.displayName ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showMessage('Google Sign-Up successful with backend: ${responseData['message']}', isError: false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
      } else {
        _showMessage('Backend authentication failed: ${response.body}');
      }
    } catch (e) {
      _showMessage('Google Sign-Up failed: $e');
    }
  }

  Future<void> _signUpWithFacebook() async {
    _showMessage('Initiating Facebook Sign-Up...', isError: false);
    try {
      final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);

      if (result.status == LoginStatus.success) {
        final at = result.accessToken;
        if (at == null) {
          _showMessage('Facebook Sign-Up failed: missing access token.');
          return;
        }

        final response = await http.post(
          Uri.parse('https://kolshy.ae/sociallogin/social/callback/'),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, String>{
            'provider': 'facebook',
            'accessToken': at.token,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          _showMessage('Facebook Sign-Up successful with backend: ${responseData['message']}', isError: false);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
        } else {
          _showMessage('Backend authentication failed: ${response.body}');
        }
      } else if (result.status == LoginStatus.cancelled) {
        _showMessage('Facebook Sign-Up cancelled.');
      } else {
        _showMessage('Facebook Sign-Up failed: ${result.message}');
      }
    } catch (e) {
      _showMessage('Facebook Sign-Up failed: $e');
    }
  }

  Future<void> _signUpWithInstagram() async {
    _showMessage('Initiating Instagram Sign-Up...', isError: false);
    try {
      const String instagramAppId = '642270335021538';
      const String redirectUri = 'https://kolshy.ae/sociallogin/social/callback/instagram.php';
      const String authorizationUrl =
          'https://api.instagram.com/oauth/authorize'
          '?client_id=$instagramAppId'
          '&redirect_uri=$redirectUri'
          '&scope=user_profile,user_media'
          '&response_type=code';

      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl,
        // NOTE: idéalement, utilisez un schéma custom (ex: "kolshy") configuré dans AndroidManifest/Info.plist
        callbackUrlScheme: "https",
      );

      final uri = Uri.parse(result);
      final String? code = uri.queryParameters['code'];
      final String? error = uri.queryParameters['error'];

      if (code != null) {
        final response = await http.post(
          Uri.parse('https://kolshy.ae/sociallogin/social/callback/instagram.php'),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, String>{'provider': 'instagram', 'code': code}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          _showMessage('Instagram Sign-Up successful with backend: ${responseData['message']}', isError: false);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
        } else {
          _showMessage('Backend authentication failed: ${response.body}');
        }
      } else if (error != null) {
        _showMessage('Instagram Sign-Up failed: ${uri.queryParameters['error_description'] ?? error}');
      } else {
        _showMessage('Instagram Sign-Up cancelled.');
      }
    } catch (e) {
      _showMessage('Instagram Sign-Up failed: $e');
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context); // peut être null si non configuré dans MaterialApp

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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

              _CustomInput(
                controller: _firstNameController,
                hintText: t?.firstName ?? 'First name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _CustomInput(
                controller: _lastNameController,
                hintText: t?.lastName ?? 'Last name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _CustomInput(
                controller: _emailController,
                hintText: t?.email ?? 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _CustomInput(
                controller: _phoneController,
                hintText: t?.phone ?? 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _CustomInput(
                controller: _passwordController,
                hintText: t?.password ?? 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 20),

              _CustomInput(
                controller: _confirmPasswordController,
                hintText: t?.passworConfirmation ?? 'Password confirmation',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureConfirm,
                toggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),

              const SizedBox(height: 16),

              Column(
                children: [
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

                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    t?.create ?? 'Create',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
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
                      t?.continueWith ?? 'Continue with',
                      style: const TextStyle(color: greyText),
                    ),
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
                  Text(
                    t?.alreadyHaveAnAccount ?? 'Already have an account?',
                    style: const TextStyle(color: greyText, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Text(
                        t?.login ?? 'Login',
                        style: const TextStyle(color: primaryPink, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
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

  // Custom widget to build a single checkbox item
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

  Widget _buildChoiceChip(String label) {
    final selected = _sellerChoice == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _sellerChoice = label),
      selectedColor: primaryPink,
      backgroundColor: inputFill,
      labelStyle: GoogleFonts.poppins(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(color: selected ? primaryPink : lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  final TextInputType keyboardType;

  const _CustomInput({
    super.key,
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