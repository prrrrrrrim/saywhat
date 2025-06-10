import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saywhat_app/pages/home.dart';

/// Web-only import (ignore if not on web)
/// Add this line ONLY when targeting web
/// (wrap with kIsWeb checks to avoid crashing on mobile)
import 'dart:html' as html;

import 'package:saywhat_app/pages/queue_page.dart';

class FileConverterPage extends StatefulWidget {
  const FileConverterPage({super.key});

  @override
  State<FileConverterPage> createState() => _FileConverterPageState();
}

class _FileConverterPageState extends State<FileConverterPage> {
  File? _selectedFile;
  Uint8List? _webFileBytes;
  String? _webFileName;
  final db = FirebaseFirestore.instance;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4','wav'],
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

  Future<bool> _startConversion() async {
  final isFileSelected = kIsWeb
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not authenticated')),
    );
    return false;
  }

  final userId = currentUser.uid;
  final fileName = kIsWeb
      ? _webFileName!
      : _selectedFile!.path.split('/').last;

  try {
    // Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('uploads/$userId/$fileName');
    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = storageRef.putData(_webFileBytes!);
    } else {
      uploadTask = storageRef.putFile(_selectedFile!);
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Create progress doc in subcollection
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("conversions")
        .doc(fileName);

    await docRef.set({
      'fileName': fileName,
      'status': 'waiting',
      'progress': 0,
      'uploadedAt': Timestamp.now(),
      'downloadUrl': downloadUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File uploaded and conversion started')),
    );

    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload failed: $e')),
    );
    return false;
  }
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        kIsWeb
            ? (_webFileName ?? 'No file selected')
            : (_selectedFile?.path.split('/').last ?? 'No file selected');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
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
        title: const Text(
          'File Converter',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
        Tooltip(
          message: 'The converter function helps you convert MP4 or WAV files into MP3 format',
          child: IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.black,
            onPressed: () {},
          ),
        ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.upload),
              label: const Text(
                'UPLOAD',
                style: TextStyle(fontSize: 18, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: DottedBorder(
                color: Colors.white60,
                strokeWidth: 1.5,
                dashPattern: [6, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child:
                      (kIsWeb && _webFileBytes == null) ||
                              (!kIsWeb && _selectedFile == null)
                          ? const Text(
                            'No file selected',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 16,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                fileName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Conversion'),
                    content: const Text('Are you sure you want to start the file converter?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(), // Cancel
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async{
                          Navigator.of(ctx).pop(); // Close confirmation dialog

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

                          bool success = await _startConversion();
                          Navigator.of(context).pop(); // Close loading spinner

                          if (success) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => const QueuePage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); // Slide in from right
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
                          }
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8DFF9),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'START',
                style: TextStyle(fontSize: 20, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
