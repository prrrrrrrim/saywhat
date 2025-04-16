import 'package:flutter/material.dart';

class TranscribePage extends StatelessWidget {
  const TranscribePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transcribe"),
        backgroundColor: const Color(0xFFECEFDA),
        foregroundColor: Colors.black, // ensures the back icon is visible
      ),
      body: const Center(
        child: Text("Transcribe Page"),
      ),
    );
  }
}
