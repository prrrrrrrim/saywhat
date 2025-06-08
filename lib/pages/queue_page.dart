import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    final userId = currentUser.uid;

    final conversionsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('conversions')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    final transcriptionsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transcriptions')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Queue"),
        backgroundColor: const Color(0xFFECEFDA),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Tooltip(
            message:
                'The queue page lets you track the progress of your current tasks.',
            child: Icon(Icons.info_outline, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF08251E),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: StreamZip([conversionsStream, transcriptionsStream]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final conversionDocs = snapshot.data?[0].docs ?? [];
          final transcriptionDocs = snapshot.data?[1].docs ?? [];

          final allDocs = [
            ...conversionDocs.map((doc) => {'type': 'conversion', 'doc': doc}),
            ...transcriptionDocs.map((doc) => {'type': 'transcription', 'doc': doc}),
          ];

          allDocs.sort((a, b) {
            final timeA = (a['doc'] as QueryDocumentSnapshot)['uploadedAt']?.toDate();
            final timeB = (b['doc'] as QueryDocumentSnapshot)['uploadedAt']?.toDate();
            return timeB.compareTo(timeA);
          });

          if (allDocs.isEmpty) {
            return const Center(child: Text("No files in queue"));
          }

          return ListView.builder(
            itemCount: allDocs.length,
            itemBuilder: (context, index) {
              final entry = allDocs[index];
              final doc = entry['doc'] as QueryDocumentSnapshot;
              final type = entry['type'] as String;
              final data = doc.data() as Map<String, dynamic>;
              final rawFileName = doc.id;
              final fileName = rawFileName.replaceAll(RegExp(r'\.mp4$', caseSensitive: false), '.mp3');
              final progress = (data['progress'] ?? 0).toDouble();
              final status = data['status'] ?? 'pending';
              final outputPath = data['outputPath'] ?? data['txtPath']; // transcriptions might have pdfPath

              return ListTile(
                leading: Icon(
                  type == 'conversion' ? Icons.music_note : Icons.text_snippet,
                  color: Colors.white,
                ),
                title: Text(
                  fileName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: status == 'done'
                    ? const Text(
                        'Completed',
                        style: TextStyle(color: Colors.green),
                      )
                    : status == 'error'
                        ? Text(
                            'Error: ${data['error'] ?? "Unknown"}',
                            style: const TextStyle(color: Colors.red),
                          )
                        : status == 'waiting'
                            ? const Text(
                                'Waiting...',
                                style: TextStyle(color: Colors.grey),
                              )
                            : LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: Colors.grey[700],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.purple,
                                ),
                              ),
                trailing: status == 'done' && outputPath != null
                    ? ElevatedButton(
                        onPressed: () async {
                          try {
                            final storageRef = FirebaseStorage.instance.ref().child(outputPath);
                            final url = await storageRef.getDownloadURL();
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Cannot launch file")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to get download URL")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD8CFE4),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Preview'),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
