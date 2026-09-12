import 'package:flutter/material.dart';

class PostFormScreen extends StatelessWidget {
  const PostFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Artikel'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Form akan dibuat di Hari ke-6'),
      ),
    );
  }
}