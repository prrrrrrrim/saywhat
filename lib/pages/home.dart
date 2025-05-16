import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saywhat_app/pages/auth_page.dart';
import 'transcribe_page.dart';
import 'file_converter_page.dart';
import 'translate_page.dart';
import 'queue_page.dart';
import 'tutorial_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for authentication state using Provider
    final User? user = Provider.of<User?>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E241C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA),
        elevation: 0,
        title: const Center(
          child: Text(
            'SayWhat',
            style: TextStyle(fontFamily: 'Serif', fontSize: 28),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle the menu
          },
        ),
        actions: [
          if (user != null) // Show additional icon if user is logged in
            IconButton(
              icon: const Icon(Icons.notifications, size: 32),
              onPressed: () {
                // Handle notifications press here
                print('Notifications tapped!');
              },
            ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {
              // Navigate to the authentication page if the user is logged out
              if (user != null) {
                FirebaseAuth.instance.signOut(); // Log out user
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _HomeCard(
              imagePath: 'assets/transcribe.jpg',
              color: const Color(0xFFE3E7D3),
              onTap: () => _navigateIfLoggedIn(context, const TranscribePage(), user),
            ),
            _HomeCard(
              imagePath: 'assets/converter.jpg',
              color: const Color(0xFFE8DEF8),
              onTap: () => _navigateIfLoggedIn(context, const FileConverterPage(), user),
            ),
            _HomeCard(
              imagePath: 'assets/translate.jpg',
              color: const Color(0xFFE8DEF8),
              onTap: () => _navigateIfLoggedIn(context, const TranslatePage(), user),
            ),
            _HomeCard(
              imagePath: 'assets/queue.jpg',
              color: const Color(0xFFE3E7D3),
              onTap: () => _navigateIfLoggedIn(context, const QueuePage(), user),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorialPage()),
            );
          },
          backgroundColor: const Color(0xFFE8DFF9),
          child: const Icon(Icons.help_outline, color: Colors.black),
        ),
    );
  }

  // Navigate based on the user's login status
  void _navigateIfLoggedIn(BuildContext context, Widget page, User? user) {
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
    }
  }
}

class _HomeCard extends StatelessWidget {
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.imagePath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.asset(imagePath)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
