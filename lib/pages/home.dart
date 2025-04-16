import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E241C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA),
        elevation: 0,
        title: const Text(
          'SayWhat',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 28,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: const [
            _HomeCard(title: "Transcribe", icon: Icons.text_snippet, color: Color(0xFFECEFDA)),
            _HomeCard(title: "File Converter", icon: Icons.compare_arrows, color: Color(0xFFE8DFF9)),
            _HomeCard(title: "Translate", icon: Icons.language, color: Color(0xFFE8DFF9)),
            _HomeCard(title: "Queue", icon: Icons.hourglass_bottom, color: Color(0xFFECEFDA)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFE8DFF9),
        child: const Icon(Icons.help_outline, color: Colors.black),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _HomeCard({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
