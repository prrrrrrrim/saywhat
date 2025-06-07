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

    final conversionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('conversions')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Queue"),
        backgroundColor: const Color(0xFFECEFDA),
        foregroundColor: Colors.black,
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.home),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF08251E),
      body: StreamBuilder<QuerySnapshot>(
        stream: conversionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No files in queue"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final fileName = doc.id;
              final progress = (data['progress'] ?? 0).toDouble();
              final status = data['status'] ?? 'pending';
              final outputPath = data['outputPath'];

              return ListTile(
                leading: const Icon(
                  Icons.hourglass_bottom,
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
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  Colors.purple,
                                ),
                              ),
                trailing: status == 'done'
                    ? ElevatedButton(
                        onPressed: () async {
                          if (outputPath != null) {
                            // Get the download URL from Firebase Storage
                            final storageRef =
                                FirebaseStorage.instance.ref().child(outputPath);

                            try {
                              final url = await storageRef.getDownloadURL();
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Download URL not available"),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Handle error (e.g., if the file doesn't exist in Firebase Storage)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to get download URL"),
                                ),
                              );
                            }
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
