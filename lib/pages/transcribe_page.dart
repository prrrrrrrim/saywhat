import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'queue_page.dart';

class TranscribePage extends StatefulWidget {
  const TranscribePage({super.key});

  @override
  State<TranscribePage> createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  String? fromLanguage;
  String? toLanguage;
  bool includeSummary = false;

  final List<String> languages = ['English', 'Chinese', 'Thai'];

  File? _selectedFile;
  Uint8List? _webFileBytes;
  String? _webFileName;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        final name = result.files.single.name;

        if (bytes != null) {
          setState(() {
            _webFileBytes = bytes;
            _webFileName = name;
          });
        }
      } else {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
        });
      }
    }
  }

  Future<bool> _startTranscription() async {
    final isFileSelected =
        kIsWeb
            ? _webFileBytes != null && _webFileName != null
            : _selectedFile != null;

    if (!isFileSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file first')),
      );
      return false;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return false;
    }

    final userId = currentUser.uid;
    final fileName =
        kIsWeb ? _webFileName! : _selectedFile!.path.split('/').last;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'uploads/$userId/$fileName',
      );
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = storageRef.putData(_webFileBytes!);
      } else {
        uploadTask = storageRef.putFile(_selectedFile!);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("transcriptions")
          .doc(fileName);

      await docRef.set({
        'fileName': fileName,
        'status': 'waiting',
        'progress': 0,
        'uploadedAt': Timestamp.now(),
        'downloadUrl': downloadUrl,
        'fromLanguage': fromLanguage,
        'toLanguage': toLanguage,
        'summary': includeSummary,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded and transcription started'),
        ),
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF092118),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text(
            'Transcribe',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upload button
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload),
                label: const Text('UPLOAD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Uploaded File Preview Box
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_file,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        kIsWeb
                            ? (_webFileName ?? 'No file selected')
                            : (_selectedFile?.path.split('/').last ??
                                'No file selected'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // From and To side-by-side
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel('From :'),
                        buildDropdown(languages, fromLanguage, (val) {
                          setState(() => fromLanguage = val);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel('To :'),
                        buildDropdown(languages, toLanguage, (val) {
                          setState(() => toLanguage = val);
                        }),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Summary checkbox
              Row(
                children: [
                  Checkbox(
                    value: includeSummary,
                    onChanged: (val) {
                      setState(() => includeSummary = val ?? false);
                    },
                  ),
                  const Text(
                    'Include SUMMARY',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Start Button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Confirm Conversion'),
                          content: const Text(
                            'Are you sure you want to start the file converter?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop();

                                // Show loading dialog with GIF
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                    child: Image.asset(
                                      'assets/panda_walk_load.gif',
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                );

                                bool success = await _startTranscription();
                                Navigator.of(context).pop();

                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const QueuePage(),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text(
                  'START',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget buildDropdown(
    List<String> items,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
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
        items:
            items.map((item) {
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


