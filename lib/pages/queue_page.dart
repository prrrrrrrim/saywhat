import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QueuePage extends StatelessWidget {
  final String fileName; // Pass the uploaded file name

  const QueuePage({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversion Queue"),
        backgroundColor: const Color(0xFFECEFDA),
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversions')
            .doc(fileName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Waiting for upload..."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final progress = (data['progress'] ?? 0).toDouble();
          final status = data['status'] ?? 'pending';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Status: $status', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Progress: ${progress.toStringAsFixed(1)}%'),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(value: progress / 100),
                ),
                const SizedBox(height: 20),
                if (status == 'done') ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(height: 10),
                  const Text(
                    'Conversion Complete!',
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                ],
                if (status == 'error') ...[
                  const Icon(Icons.error, color: Colors.red, size: 32),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${data['error'] ?? "Unknown"}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
