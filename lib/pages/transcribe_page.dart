import 'package:flutter/material.dart';

class TranscribePage extends StatefulWidget {
  const TranscribePage({super.key});

  @override
  State<TranscribePage> createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  String? fromLanguage;
  String? toLanguage;
  String? template;
  String? format;

  final List<String> languages = ['English', 'Chinese', 'Thai'];
  final List<String> templates = ['Lecture', 'Meeting', 'Conference', 'Interview'];
  final List<String> formats = ['Text', 'PDF', 'DOCX'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF092118), // Dark green
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA), // Pale green
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context); // Back to home
          },
        ),
        title: Center(
          child: const Text(
            'Transcribe',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Button
            ElevatedButton.icon(
              onPressed: () {
                // Handle upload
              },
              icon: const Icon(Icons.upload),
              label: const Text('UPLOAD'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),

            // From Language Dropdown
            buildLabel('From :'),
            buildDropdown(languages, fromLanguage, (val) {
              setState(() => fromLanguage = val);
            }),

            const SizedBox(height: 16),

            // To Language Dropdown
            buildLabel('To :'),
            buildDropdown(languages, toLanguage, (val) {
              setState(() => toLanguage = val);
            }),

            const SizedBox(height: 16),

            // Template Dropdown
            buildLabel('Template :'),
            buildDropdown(templates, template, (val) {
              setState(() => template = val);
            }),

            const SizedBox(height: 16),

            // Format Dropdown
            buildLabel('Format :'),
            buildDropdown(formats, format, (val) {
              setState(() => format = val);
            }),

            const SizedBox(height: 32),

            // START Button
            ElevatedButton(
              onPressed: () {
                // Handle start transcription
              },
              child: const Text('START'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8DFF9), // Lavender
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Sans',
        ),
      ),
    );
  }

  Widget buildDropdown(List<String> items, String? selected, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: selected,
        hint: const Text('Choose an option'),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
