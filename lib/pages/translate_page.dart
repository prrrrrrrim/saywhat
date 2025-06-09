import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import Cloud Functions package
import 'package:saywhat_app/pages/home.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = 'Translation';
  String? _fromLang;
  String? _toLang;

  final List<String> _languages = ['English', 'Chinese', 'Thai'];

  void _translateText() async {
    try {
      String textToTranslate = _inputController.text;

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'translateText',
      );

      final response = await callable.call({
        'text': textToTranslate,
        'targetLang': _toLang,
        'fromLang': _fromLang,
      });

      if (response.data != null && response.data['translation'] != null) {
        String translated = response.data['translation'];

        setState(() {
          _translatedText = translated;
        });
      } else {
        setState(() {
          _translatedText = 'Translation failed or no content returned.';
        });
      }
    } catch (error) {
      setState(() {
        _translatedText = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreen = Colors.black;
    final Color lightPurple = const Color(0xFFE7DDF7);

    return Scaffold(
      backgroundColor: darkGreen,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAEBD5),
        title: const Text('Translate', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // Slide from left
                  const end = Offset.zero;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
                  final offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        actions: [
        Tooltip(
          message: 'The translate function lets you translate into the language you want',
          child: IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.black,
            onPressed: () {},
          ),
        ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _fromLang,
              items: _languages
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (value) => setState(() => _fromLang = value),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Choose a language",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              onSubmitted: (_) => _translateText(), // Trigger on Enter
              maxLines: 6,
              maxLength: 1000,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Typed here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _translateText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Translate"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _toLang,
              items: _languages
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (value) => setState(() => _toLang = value),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Choose a language",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _translatedText,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
