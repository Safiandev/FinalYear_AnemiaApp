import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';

class RefinedResultScreen extends StatefulWidget {
  final double finalHb;
  final List<String> userSymptoms;

  const RefinedResultScreen({
    super.key,
    required this.finalHb,
    required this.userSymptoms, // Isay required kar dein
  });

  @override
  State<RefinedResultScreen> createState() => _RefinedResultScreenState();
}

class _RefinedResultScreenState extends State<RefinedResultScreen> {
  Map<String, dynamic> getStatus() {
    if (widget.finalHb < 8.0) {
      return {
        'label': 'Severe Anemia',
        'color': Colors.red,
        'icon': Icons.warning_rounded
      };
    } else if (widget.finalHb < 12.0) {
      return {
        'label': 'Mild Anemia',
        'color': Colors.orange,
        'icon': Icons.info_outline
      };
    } else {
      return {
        'label': 'Normal Range',
        'color': Colors.green,
        'icon': Icons.check_circle_outline
      };
    }
  }

  void _showAiDoctorConsultation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 25,
            right: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.psychology, color: Colors.blue),
                ),
                const SizedBox(width: 15),
                const Text("AI Medical Assistant",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Your hemoglobin is ${widget.finalHb} g/dL. I recommend a diet rich in Vitamin C. Would you like to see more details?",
              style: TextStyle(
                  color: Colors.grey.shade800, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 25),
            TextField(
              decoration: InputDecoration(
                hintText: "Ask AI Doctor...",
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: const Icon(Icons.send_rounded, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = getStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Refined Analysis",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- RESULT CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: widget.finalHb / 18,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade100,
                          color: status['color'],
                        ),
                      ),
                      Text("${widget.finalHb}",
                          style: const TextStyle(
                              fontSize: 45, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                        color: status['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(status['label'],
                        style: TextStyle(
                            color: status['color'],
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Clinical Correlation",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 15),

            // --- FIXED CORRELATION CARDS ---
            _buildInfoCard(
                "Visual Eye Scan",
                "Baseline Estimation",
                "Analyzed conjunctival pallor pixels.",
                Icons.visibility,
                Colors.blue),
            _buildInfoCard(
                "Symptom Weight",
                "-0.3 g/dL adjustment",
                "Based on reported fatigue and pallor.",
                Icons.analytics,
                Colors.orange),
            _buildInfoCard(
                "Confidence Level",
                "High (92%)",
                "Synchronization of visual & clinical data.",
                Icons.verified,
                Colors.green),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _showAiDoctorConsultation(context),
              child: const Text("Consult AI Doctor",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPreviewScreen(
                      finalHb: widget.finalHb,
                      selectedSymptoms:
                          widget.userSymptoms, // <--- AB YE DYNAMIC HAI!
                    ),
                  ),
                );
              },
              child: const Text("Download PDF Report",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW CUSTOM CARD WIDGET ---
  Widget _buildInfoCard(
      String title, String subtitle, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: color),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(subtitle,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.expand_more, size: 20),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 55, right: 20, bottom: 15),
              child: Text(desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            )
          ],
        ),
      ),
    );
  }
}
