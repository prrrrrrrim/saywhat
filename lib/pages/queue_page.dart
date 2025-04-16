import 'package:flutter/material.dart';


class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Queue"),
        backgroundColor: const Color(0xFFECEFDA),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text("Queue Page"),
      ),
    );
  }
}
