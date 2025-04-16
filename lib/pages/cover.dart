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
        backgroundColor: const Color(0xE8ECEFDA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.language, size: 120), // Replace with your custom globe/chat icon if needed
              const SizedBox(height: 30),
              const Text(
                'SayWhat',
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 80),
              const Text(
                'Tap To Start',
                style: TextStyle(
                  fontSize: 24,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
