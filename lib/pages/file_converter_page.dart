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
      allowedExtensions: ['mp4'],
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

  Future<void> _startConversion() async {
    // Ensure file is selected before continuing
    final isFileSelected =
        kIsWeb
            ? _webFileBytes != null && _webFileName != null
            : _selectedFile != null;

    if (!isFileSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file first')),
      );
      return;
    }

    // Get the current authenticated user
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Handle user not authenticated
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    final userId = currentUser.uid;
    final fileName =
        kIsWeb ? _webFileName! : _selectedFile!.path.split('/').last;

    try {
      // Prepare the API request (you can still send the file to backend when ready)
      final uri = Uri.parse(
        'https://convertmp4tomp3-949354399842.us-central1.run.app/',
      );
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _webFileBytes!,
            filename: _webFileName!,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', _selectedFile!.path),
        );
      }

      // Upload the file to Firebase Storage (if needed, or save metadata)
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

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection("converted_files").add({
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'userId': userId,
        'uploadedAt': Timestamp.now(),
        'status': 'waiting',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded and queued')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QueuePage()),
    );
  }
  /*ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading and converting...')),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();

        if (kIsWeb) {
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", _webFileName!.replaceAll('.mp4', '.mp3'))
            ..click();
          html.Url.revokeObjectUrl(url);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started!')),
          );
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              path.basename(_selectedFile!.path).replaceAll('.mp4', '.mp3');
          final filePath = path.join(directory.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded: $fileName')),
          );

          final player = AudioPlayer();
          await player.play(DeviceFileSource(filePath));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversion failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }*/

  @override
  Widget build(BuildContext context) {
    final fileName =
        kIsWeb
            ? (_webFileName ?? 'No file selected')
            : (_selectedFile?.path.split('/').last ?? 'No file selected');

    return Scaffold(
      backgroundColor: const Color(0xFF0E241C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEFDA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context);
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
              onPressed: _startConversion,
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
