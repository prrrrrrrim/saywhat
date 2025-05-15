import 'package:flutter/material.dart';
import 'package:saywhat_app/pages/auth_page.dart';
import 'transcribe_page.dart';
import 'file_converter_page.dart';
import 'translate_page.dart';
import 'queue_page.dart';
import 'tutorial_page.dart';
// import 'package:saywhat_app/service/auth.dart';

bool isLoggedIn = true; // for now, replace with real auth logic

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showHistory = false;

  void _toggleHistoryDrawer() {
    setState(() {
      _showHistory = !_showHistory;
    });
  }

  void _navigateIfLoggedIn(Widget page) {
    if (isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              onPressed: _toggleHistoryDrawer,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                },
              )
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
                  onTap: () => _navigateIfLoggedIn(const TranscribePage()),
                ),
                _HomeCard(
                  imagePath: 'assets/converter.jpg',
                  color: const Color(0xFFE8DEF8),
                  onTap: () => _navigateIfLoggedIn(const FileConverterPage()),
                ),
                _HomeCard(
                  imagePath: 'assets/translate.jpg',
                  color: const Color(0xFFE8DEF8),
                  onTap: () => _navigateIfLoggedIn(const TranslatePage()),
                ),
                _HomeCard(
                  imagePath: 'assets/queue.jpg',
                  color: const Color(0xFFE3E7D3),
                  onTap: () => _navigateIfLoggedIn(const QueuePage()),
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

        ),

        // Slide-in History Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: 0,
          bottom: 0,
          left: _showHistory ? 0 : -MediaQuery.of(context).size.width * 0.6,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Material(
              color: Colors.black,
              elevation: 8,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'History',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search history...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Log In', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_showHistory)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleHistoryDrawer,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
      ],
    );
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
