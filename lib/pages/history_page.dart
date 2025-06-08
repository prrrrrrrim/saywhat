import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:saywhat_app/pages/auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDrawer extends StatelessWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                user != null
                    ? _buildHistoryList(user.uid)
                    : const Center(
                      child: Text(
                        'Please log in to view history.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
          ),
          const Divider(color: Colors.white24),
          _buildLoginOrLogoutButton(context, user),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHistoryList(String userId) {
    final historyStream =
        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("transcriptions")
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: historyStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No history found.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final fileName = doc.id;
            final txtPath = data['txtPath'] as String?;

            return ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: Text(
                fileName,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                if (txtPath != null) {
                  final storageRef = FirebaseStorage.instance.ref().child(
                    txtPath,
                  );
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
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoginOrLogoutButton(BuildContext context, User? user) {
    if (user != null) {
      return ListTile(
        leading: const Icon(Icons.logout, color: Colors.white),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pop(context); // Close the drawer
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.login, color: Colors.white),
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        },
      );
    }
  }
}
