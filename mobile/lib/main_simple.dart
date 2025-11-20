import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Agent Chat',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AI Agent Chat'),
        ),
        body: const Center(
          child: Text(
            'Hello! The app is working!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

