import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileConverterPage extends StatefulWidget {
  const FileConverterPage({super.key});

  @override
  State<FileConverterPage> createState() => _FileConverterPageState();
}

class _FileConverterPageState extends State<FileConverterPage> {
  File? _selectedFile;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _startConversion() {
    // TODO: Add actual conversion logic
    if (_selectedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting conversion for ${_selectedFile!.path.split('/').last}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  child: _selectedFile == null
                      ? const Text(
                          'No file selected',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insert_drive_file, size: 64, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
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
