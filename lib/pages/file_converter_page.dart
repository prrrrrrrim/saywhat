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

// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// class FileConverterPage extends StatefulWidget {
//   const FileConverterPage({super.key});

//   @override
//   State<FileConverterPage> createState() => _FileConverterPageState();
// }

// class _FileConverterPageState extends State<FileConverterPage> {
//   PlatformFile? pickedFile;

//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp4', 'wav', 'mp3', 'mov', 'm4a', 'pdf', 'docx'],
//     );
//     if (result != null && result.files.isNotEmpty) {
//       setState(() => pickedFile = result.files.first);
//     }
//   }

//   void _startConversion() {
//     if (pickedFile == null) return;

//     // TODO: Implement call to Firebase Function / Genkit backend here
//     print("Converting: ${pickedFile!.name}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF081F17),
//       appBar: AppBar(
//         title: const Text('File Converter'),
//         backgroundColor: const Color(0xFFE8EAD2),
//         leading: const Icon(Icons.home),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: _pickFile,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//               ),
//               icon: const Icon(Icons.upload),
//               label: const Text("UPLOAD"),
//             ),
//             const SizedBox(height: 40),
//             Container(
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 border: Border.all(style: BorderStyle.solid, color: Colors.white70, width: 1),
//               ),
//               child: Center(
//                 child: pickedFile != null
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.insert_drive_file, size: 64, color: Colors.white70),
//                           Text(
//                             pickedFile!.name,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       )
//                     : const Text(
//                         "No file selected",
//                         style: TextStyle(color: Colors.white70),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: _startConversion,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xE5E0ECFF),
//                 foregroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//               ),
//               child: const Text("START"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

