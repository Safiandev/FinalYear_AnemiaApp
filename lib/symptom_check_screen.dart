import 'package:flutter/material.dart';

class SymptomCheckScreen extends StatelessWidget {
  const SymptomCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Check'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text(
          'This is the Symptom Check screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
