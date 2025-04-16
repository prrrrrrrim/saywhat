import 'package:flutter/material.dart';
import 'home.dart';

class CoverPage extends StatelessWidget {
  const CoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECEFDA), // light beige/greenish tone
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              // App name
              const Text(
                'SayWhat',
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'Serif',
                ),
              ),
              const Spacer(flex: 4),
              // Tap to start text
              const Text(
                'Tap To Start',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'monospace',
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
