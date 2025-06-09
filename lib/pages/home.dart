import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saywhat_app/pages/auth_page.dart';
import 'transcribe_page.dart';
import 'file_converter_page.dart';
import 'translate_page.dart';
import 'queue_page.dart';
import 'tutorial_page.dart';
import 'history_page.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA),
        elevation: 0,
        title: const Center(
          child: Text(
            'SayWhat',
            style: TextStyle(fontFamily: 'Serif', fontSize: 28),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.help_outline, size: 32, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorialPage()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {
              if (user != null) {
                FirebaseAuth.instance.signOut();
              } else {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // Bottom to top
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: const HistoryDrawer(), // link to history drawer
      body: Padding(
  padding: const EdgeInsets.all(20),
  child: AnimationLimiter(
    child: GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: List.generate(4, (index) {
        final items = [
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
        ];

        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: 2,
          child: SlideAnimation(
            verticalOffset: 50.0,
            curve: Curves.easeOutCubic,
            child: FadeInAnimation(
              child: items[index],
            ),
          ),
        );
      }),
    ),
  ),
),

      floatingActionButton: user == null
    ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const TutorialPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        },
        backgroundColor: const Color(0xFFE8DFF9),
        child: const Icon(Icons.help_outline, color: Colors.black),
      )
    : null,
    );
  }

 void _navigateIfLoggedIn(BuildContext context, Widget page, User? user) {
    if (user != null) {
      // Slide from right to left if logged in
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Right to left
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Slide from bottom to top if not logged in
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Bottom to top
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
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