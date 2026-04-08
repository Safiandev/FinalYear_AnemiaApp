import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart'; // ✅ Added import

class PreviousReportsScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const PreviousReportsScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = UserProvider.userId ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Health Analytics',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Colors.black),
          onPressed: () =>
              onBackToHome != null ? onBackToHome!() : Navigator.pop(context),
        ),
      ),
      body: currentUserId.isEmpty
          ? const Center(child: Text("Please login to see records"))
          : StreamBuilder<QuerySnapshot>(
              // ✅ Logic Fix: Order by timestamp directly from Firestore
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('userId', isEqualTo: currentUserId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.blue));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final reports = snapshot.data!.docs;

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    const Text('Hemoglobin Trends',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142))),
                    const SizedBox(height: 15),
                    // ✅ Only passing completed reports to graph for accurate trends
                    _buildProfessionalGraph(reports),
                    const SizedBox(height: 30),
                    const Text('Recent Activity',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2D3142))),
                    const SizedBox(height: 15),
                    ...reports.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String docId = doc.id; // ✅ ID for resuming test
                      return _buildReportCard(context, data, docId);
                    }).toList(),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
    );
  }

  // --- 📈 PROFESSIONAL GRAPH UI ---
  Widget _buildProfessionalGraph(List<QueryDocumentSnapshot> reports) {
    double total = 0;
    int count = 0;
    List<double> dataPoints = [];

    // Reverse for chronological graph (Left to Right)
    for (var doc in reports.reversed) {
      final data = doc.data() as Map<String, dynamic>;

      // ✅ Logic Fix: Only include completed reports in the graph
      if (data['isCompleted'] == true) {
        double val = double.tryParse(data['hbValue']?.toString() ?? "0") ?? 0;
        if (val > 0) {
          total += val;
          count++;
          dataPoints.add(val);
        }
      }
    }

    double avg = count > 0 ? total / count : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Average Level",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              if (avg > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: avg >= 12
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(avg >= 12 ? "Optimal" : "Attention",
                      style: TextStyle(
                          color: avg >= 12 ? Colors.green : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: 5),
          Text("${avg.toStringAsFixed(1)} g/dL",
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: dataPoints.length < 2
                ? const Center(
                    child: Text("Need more data for trends",
                        style: TextStyle(fontSize: 12, color: Colors.grey)))
                : CustomPaint(painter: _AreaChartPainter(dataPoints)),
          ),
        ],
      ),
    );
  }

  // --- 📋 REPORT CARD UI ---
  Widget _buildReportCard(
      BuildContext context, Map<String, dynamic> data, String docId) {
    DateTime date =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);

    bool isCompleted = data['isCompleted'] == true;
    String hbValue = data['hbValue']?.toString() ?? "0.0";
    String status = data['statusLabel'] ?? "Normal Range";

    Color themeColor = isCompleted ? Colors.blueAccent : Colors.orangeAccent;
    if (isCompleted && status.toLowerCase().contains('anemia')) {
      themeColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          // ✅ Resume Test Logic
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SymptomQuestionnaireScreen(
                reportId: docId,
                initialHb: double.tryParse(hbValue) ?? 12.0,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isCompleted ? Colors.transparent : Colors.orange.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                  isCompleted
                      ? Icons.check_circle_outline
                      : Icons.pending_actions,
                  color: themeColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text("$hbValue g/dL",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCompleted ? status : "Incomplete",
                    style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text("Finish Test >",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text("No Records Yet",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          const Text("Start your first health checkup now.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// Painter class remains the same but with safety checks already handled in build
class _AreaChartPainter extends CustomPainter {
  final List<double> points;
  _AreaChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    double dx = size.width / (points.length - 1);
    double maxY = 18.0;

    for (int i = 0; i < points.length; i++) {
      double x = i * dx;
      double y = size.height - (points[i] / maxY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
