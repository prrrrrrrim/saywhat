import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saywhat_app/pages/auth_page.dart';

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
            child: user != null
                ? _buildHistoryList() // Show user history
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

  Widget _buildHistoryList() {
    // You can replace this with your actual list of history
    final dummyHistory = [
      'Converted file: notes.mp4',
      'Translated text: hello world',
      'Transcribed: interview.wav',
    ];

    return ListView.builder(
      itemCount: dummyHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.white),
          title: Text(
            dummyHistory[index],
            style: const TextStyle(color: Colors.white),
          ),
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
