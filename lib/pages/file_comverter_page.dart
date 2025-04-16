import 'package:flutter/material.dart';

class FileConverterPage extends StatelessWidget {
  const FileConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Converter"),
        backgroundColor: const Color(0xFFECEFDA),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text("File Converter Page"),
      ),
    );
  }
}
