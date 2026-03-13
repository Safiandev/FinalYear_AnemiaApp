import 'package:flutter/material.dart';
import 'result_screen.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  double progress = 0.0;
  int percent = 0;
  bool imageCheckDone = false;

  @override
  void initState() {
    super.initState();
    startAnalysis();
  }

  void startAnalysis() async {
    // ---------- STEP 1 : IMAGE QUALITY CHECK ----------
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      imageCheckDone = true;
      progress = 0.30;
      percent = 30;
    });

    // ---------- STEP 2 : TISSUE ANALYSIS ----------
    for (int i = 30; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 120));

      setState(() {
        percent = i;
        progress = i / 100;
      });
    }

    // ---------- RESULT SCREEN ----------
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Analysis', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      // ---------- BODY ----------
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ---------- CIRCLE PROGRESS ----------
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    color: Colors.blue,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),

                Column(
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PROCESSING',
                      style: TextStyle(letterSpacing: 1, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ---------- TITLE ----------
            const Text(
              'Analyzing Hemoglobin Level...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Our AI is examining the conjunctiva color patterns to estimate your blood health markers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // ---------- IMAGE QUALITY CHECK ----------
            _analysisRow(
              icon: Icons.check_circle,
              title: 'Image Quality Check',
              value: imageCheckDone ? 'Complete' : 'Processing',
              done: imageCheckDone,
            ),

            const SizedBox(height: 20),

            // ---------- TISSUE ANALYSIS ----------
            _analysisRow(
              icon: Icons.analytics,
              title: 'Tissue Analysis',
              value: '$percent%',
              done: percent == 100,
            ),

            const SizedBox(height: 8),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Neural nodes pulsing...',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const Spacer(),

            // ---------- SECURITY NOTE ----------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Encrypted and secure clinical analysis'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- ANALYSIS ROW ----------
  Widget _analysisRow({
    required IconData icon,
    required String title,
    required String value,
    required bool done,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: done ? Colors.green : Colors.blue),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),

        Text(
          value,
          style: TextStyle(
            color: done ? Colors.green : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
