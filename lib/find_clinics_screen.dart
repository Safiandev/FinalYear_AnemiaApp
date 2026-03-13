import 'package:flutter/material.dart';

class FindClinicsScreen extends StatelessWidget {
  const FindClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Clinics'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text(
          'This is the Find Clinics screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
