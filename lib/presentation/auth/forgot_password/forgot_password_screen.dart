import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/presentation/auth/forgot_password/verification_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/api_client.dart';

const Color primaryPink = Color(0xFFE51742);
const Color inputFill = Color(0xFFF4F4F4);
const Color lightBorder = Color(0xFFDDDDDD);
const Color greyText = Color(0xFF777777);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final RegExp emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  bool _isChecked = false;

  void _submit() async {
    final email = _emailController.text.trim();

    if (!_isChecked) {
      _showSnackbar(AppLocalizations.of(context)?.checkBoxMsg ?? 'Please check the box to proceed.');
      return;
    }
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showSnackbar(AppLocalizations.of(context)?.invalidEmail ?? 'Invalid email format');
      return;
    }

    try {
      await ApiClient().requestPasswordReset(email: email);
      _showSnackbar(AppLocalizations.of(context)?.mailSent ?? 'Reset email sent', isError: false);

    } catch (e) {
      _showSnackbar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationCodeScreen(email: _emailController.text.trim()),
      ),
    );

  }

  void _showSnackbar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)?.forgotPwd ?? "Forgot Password",
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 36),

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFill,
                  hintText: AppLocalizations.of(context)?.enterEmail ?? "Enter your email",
                  hintStyle: const TextStyle(color: greyText),
                  prefixIcon: const Icon(Icons.email_outlined, color: greyText),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: lightBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: lightBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: primaryPink),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: primaryPink,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.resetPwd ?? "I want to reset my password",
                      style: const TextStyle(color: greyText, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.submit ?? "Submit",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}