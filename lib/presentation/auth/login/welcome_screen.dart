import 'package:flutter/material.dart';

/// Page d'accueil (welcome) – style basé sur la maquette fournie.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/welcome_background.jpeg'),
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
              ),
            ),
          ),


          Container(
            color: Colors.black.withOpacity(0.25),
          ),


          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25
                  ),
                  Text(
                    "Manage Your Business,\nAnytime, Anywhere",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      fontSize: 34,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/kolshy_logo.gif',
                        width: 200,
                        height: 120,
                      ),
                    ],
                  ),


                  const _Subtitle(),
                  const SizedBox(height: 28),

                  _PrimaryButton(
                    label: "Sign up",
                    onPressed: () {
                      // TODO: Naviguer vers la page d'inscription
                    },
                  ),
                  const SizedBox(height: 14),
                  _SecondaryButton(
                    label: "Sign In",
                    onPressed: () {
                      // TODO: Naviguer vers la page de connexion
                    },
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Colors.white.withOpacity(0.92),
      fontWeight: FontWeight.w600,
      height: 1.35,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Track orders, manage products,",
          textAlign: TextAlign.center,
          style: style,
        ),
        Text(
          "and grow your sales directly from your phone",
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0F12).withOpacity(0.55),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0F12).withOpacity(0.35),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}