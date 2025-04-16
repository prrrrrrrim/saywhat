import 'package:flutter/material.dart';
import 'transcribe_page.dart';
import 'file_converter_page.dart';
import 'translate_page.dart';
import 'queue_page.dart';

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
          children: [
            _HomeCard(
              title: "Transcribe",
              imagePath: 'assets/transcribe.jpg',
              color: const Color(0xFFECEFDA),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TranscribePage()));
              },
            ),
            _HomeCard(
              title: "File Converter",
              imagePath: 'assets/converter.jpg',
              color: const Color(0xFFE8DFF9),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FileConverterPage()));
              },
            ),
            _HomeCard(
              title: "Translate",
              imagePath: 'assets/translate.jpg',
              color: const Color(0xFFE8DFF9),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslatePage()));
              },
            ),
            _HomeCard(
              title: "Queue",
              imagePath: 'assets/queue.jpg',
              color: const Color(0xFFECEFDA),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QueuePage()));
              },
            ),
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
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
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
            Expanded(
              child: Image.asset(imagePath),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
