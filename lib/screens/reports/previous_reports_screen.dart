import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';

class PreviousReportsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const PreviousReportsScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<PreviousReportsScreen> createState() => _PreviousReportsScreenState();
}

class _PreviousReportsScreenState extends State<PreviousReportsScreen> {
  String _filterType =
      'All'; // Options: 'All', '1W', '1M', '3M', 'Custom Date', 'Month & Year'
  DateTime? _selectedCustomDate;
  DateTime? _selectedMonthYear;

// --- DATE PICKER FOR SPECIFIC DATE ---
  Future<void> _pickCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedCustomDate = picked;
        _filterType = 'Custom Date';
      });
    }
  }

// --- MONTH & YEAR PICKER ---
  Future<void> _pickMonthYear() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonthYear = picked;
        _filterType = 'Month & Year';
      });
    }
  }

  // --- HELPER TO OPEN EXACT SCAN REPORT PDF PREVIEW ---
  void _openReportPreview(Map<String, dynamic> data) {
    // 1. Extract Hb Value safely
    final dynamic rawHb = data['hbValue'] ??
        data['finalHb'] ??
        data['hb_level'] ??
        data['hb'] ??
        data['hemoglobin'] ??
        0.0;
    final double hbVal = (rawHb is num)
        ? rawHb.toDouble()
        : double.tryParse(rawHb.toString()) ?? 0.0;

    // 2. Extract Symptoms safely
    final dynamic rawSymptoms = data['symptoms'] ?? data['userSymptoms'] ?? [];
    final List<String> symptomsList = (rawSymptoms is List)
        ? rawSymptoms.map((s) => s.toString()).toList()
        : [];

    // 3. Open ReportPreviewScreen (Same as RefinedResultScreen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPreviewScreen(
          finalHb: hbVal,
          selectedSymptoms: symptomsList,
        ),
      ),
    );
  }

  double _extractHbValue(Map<String, dynamic> data) {
    var raw = data['hbValue'] ??
        data['finalHb'] ??
        data['hb_level'] ??
        data['hb'] ??
        data['hemoglobin'] ??
        data['result'];
    if (raw == null) return 0.0;
    return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;
  }

  DateTime _parseTimestamp(dynamic rawTimestamp) {
    if (rawTimestamp is Timestamp) {
      return rawTimestamp.toDate();
    } else if (rawTimestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      return DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // ❌ Purana _filterReports method hata kar is se replace karein:
  List<Map<String, dynamic>> _filterReports(
      List<Map<String, dynamic>> rawReports) {
    if (_filterType == 'All') return rawReports;

    DateTime now = DateTime.now();

    return rawReports.where((r) {
      DateTime reportDate = _parseTimestamp(r['timestamp'] ?? r['createdAt']);

      if (_filterType == '1W') {
        return reportDate.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_filterType == '1M') {
        return reportDate.isAfter(DateTime(now.year, now.month - 1, now.day));
      } else if (_filterType == '3M') {
        return reportDate.isAfter(DateTime(now.year, now.month - 3, now.day));
      } else if (_filterType == 'Custom Date' && _selectedCustomDate != null) {
        return reportDate.year == _selectedCustomDate!.year &&
            reportDate.month == _selectedCustomDate!.month &&
            reportDate.day == _selectedCustomDate!.day;
      } else if (_filterType == 'Month & Year' && _selectedMonthYear != null) {
        return reportDate.year == _selectedMonthYear!.year &&
            reportDate.month == _selectedMonthYear!.month;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Health Analytics',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          List<Map<String, dynamic>> allReports = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          allReports.sort((a, b) {
            DateTime tA = _parseTimestamp(a['timestamp'] ?? a['createdAt']);
            DateTime tB = _parseTimestamp(b['timestamp'] ?? b['createdAt']);
            return tA.compareTo(tB);
          });

          List<Map<String, dynamic>> filteredReports =
              _filterReports(allReports);
          List<Map<String, dynamic>> recentList =
              List.from(filteredReports.reversed);

          double avgHb = filteredReports.isNotEmpty
              ? filteredReports
                      .map((r) => _extractHbValue(r))
                      .reduce((a, b) => a + b) /
                  filteredReports.length
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterDropdown(),
                const SizedBox(height: 16),
                _buildGraphCard(filteredReports, avgHb),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${recentList.length} Reports',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                recentList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No reports found for selected filter duration.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentList.length,
                        itemBuilder: (context, index) {
                          final report = recentList[index];
                          return _buildReportItemTile(report);
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterDropdown() {
    String displayLabel = _filterType;
    if (_filterType == 'Custom Date' && _selectedCustomDate != null) {
      displayLabel = DateFormat('dd MMM yyyy').format(_selectedCustomDate!);
    } else if (_filterType == 'Month & Year' && _selectedMonthYear != null) {
      displayLabel = DateFormat('MMMM yyyy').format(_selectedMonthYear!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Filter: $displayLabel',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
              value: null,
              hint: const Text('Change',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold)),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Reports')),
                DropdownMenuItem(value: '1W', child: Text('Last 1 Week')),
                DropdownMenuItem(value: '1M', child: Text('Last 1 Month')),
                DropdownMenuItem(value: '3M', child: Text('Last 3 Months')),
                DropdownMenuItem(
                    value: 'CUSTOM_DATE',
                    child: Text('Select Specific Date 📅')),
                DropdownMenuItem(
                    value: 'MONTH_YEAR',
                    child: Text('Select Month & Year 🗓️')),
              ],
              onChanged: (value) {
                if (value == 'CUSTOM_DATE') {
                  _pickCustomDate();
                } else if (value == 'MONTH_YEAR') {
                  _pickMonthYear();
                } else if (value != null) {
                  setState(() {
                    _filterType = value;
                    _selectedCustomDate = null;
                    _selectedMonthYear = null;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(List<Map<String, dynamic>> reports, double avgHb) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Average Level',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        avgHb.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const Text(' g/dL',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: avgHb < 12.0
                      ? Colors.amber.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  avgHb < 12.0 ? 'Attention' : 'Optimal',
                  style: TextStyle(
                    fontSize: 11,
                    color: avgHb < 12.0
                        ? Colors.amber.shade900
                        : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: reports.isEmpty
                ? const Center(child: Text("No Data for Chart"))
                : LineChart(
                    LineChartData(
                      minY: 8.0,
                      maxY: 18.0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              if (value == 8 || value == 12 || value == 16) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < reports.length) {
                                DateTime d = _parseTimestamp(reports[index]
                                        ['timestamp'] ??
                                    reports[index]['createdAt']);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    DateFormat('d MMM').format(d),
                                    style: const TextStyle(
                                        fontSize: 9, color: Colors.grey),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: reports.asMap().entries.map((e) {
                            return FlSpot(
                                e.key.toDouble(), _extractHbValue(e.value));
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: reports.length < 10),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItemTile(Map<String, dynamic> report) {
    double hb = _extractHbValue(report);
    DateTime date = _parseTimestamp(report['timestamp'] ?? report['createdAt']);
    String status = report['status'] ??
        (hb < 8.0 ? 'Severe' : (hb < 12.0 ? 'Mild Anemia' : 'Normal'));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.check_circle, color: Colors.red.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('MMM dd, yyyy').format(date)}  •  ${DateFormat('hh:mm a').format(date)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  '${hb.toStringAsFixed(1)} g/dL',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),

          // DOWNLOAD / VIEW PDF REPORT BUTTON (Triggers ReportPreviewScreen)
          InkWell(
            onTap: () => _openReportPreview(report),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50, // Subtle blue background
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, color: Colors.blue, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'PDF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text('No Medical History Found',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Your completed scan tests will appear here.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:hemoglobe_ai/user_provider.dart';
// import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart'; // ✅ Added import

// class PreviousReportsScreen extends StatelessWidget {
//   final VoidCallback? onBackToHome;

//   const PreviousReportsScreen({super.key, this.onBackToHome});

//   @override
//   Widget build(BuildContext context) {
//     final String currentUserId = UserProvider.userId ?? "";

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Health Analytics',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//                 color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               size: 20, color: Colors.black),
//           onPressed: () =>
//               onBackToHome != null ? onBackToHome!() : Navigator.pop(context),
//         ),
//       ),
//       body: currentUserId.isEmpty
//           ? const Center(child: Text("Please login to see records"))
//           : StreamBuilder<QuerySnapshot>(
//               // ✅ Logic Fix: Order by timestamp directly from Firestore
//               stream: FirebaseFirestore.instance
//                   .collection('reports')
//                   .where('userId', isEqualTo: currentUserId)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.blue));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return _buildEmptyState();
//                 }

//                 final reports = snapshot.data!.docs;

//                 return ListView(
//                   physics: const BouncingScrollPhysics(),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   children: [
//                     const Text('Hemoglobin Trends',
//                         style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2D3142))),
//                     const SizedBox(height: 15),
//                     // ✅ Only passing completed reports to graph for accurate trends
//                     _buildProfessionalGraph(reports),
//                     const SizedBox(height: 30),
//                     const Text('Recent Activity',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Color(0xFF2D3142))),
//                     const SizedBox(height: 15),
//                     ...reports.map((doc) {
//                       var data = doc.data() as Map<String, dynamic>;
//                       String docId = doc.id; // ✅ ID for resuming test
//                       return _buildReportCard(context, data, docId);
//                     }),
//                     const SizedBox(height: 20),
//                   ],
//                 );
//               },
//             ),
//     );
//   }

//   // --- 📈 PROFESSIONAL GRAPH UI ---
//   Widget _buildProfessionalGraph(List<QueryDocumentSnapshot> reports) {
//     double total = 0;
//     int count = 0;
//     List<double> dataPoints = [];

//     // Reverse for chronological graph (Left to Right)
//     for (var doc in reports.reversed) {
//       final data = doc.data() as Map<String, dynamic>;

//       // ✅ Logic Fix: Only include completed reports in the graph
//       if (data['isCompleted'] == true) {
//         double val = double.tryParse(data['hbValue']?.toString() ?? "0") ?? 0;
//         if (val > 0) {
//           total += val;
//           count++;
//           dataPoints.add(val);
//         }
//       }
//     }

//     double avg = count > 0 ? total / count : 0;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 15,
//               offset: const Offset(0, 5))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text("Average Level",
//                   style: TextStyle(color: Colors.grey, fontSize: 14)),
//               if (avg > 0)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: avg >= 12
//                           ? Colors.green.shade50
//                           : Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(8)),
//                   child: Text(avg >= 12 ? "Optimal" : "Attention",
//                       style: TextStyle(
//                           color: avg >= 12 ? Colors.green : Colors.orange,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold)),
//                 )
//             ],
//           ),
//           const SizedBox(height: 5),
//           Text("${avg.toStringAsFixed(1)} g/dL",
//               style: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2D3142))),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 500,
//             width: double.infinity,
//             child: dataPoints.length < 2
//                 ? const Center(
//                     child: Text("Need more data for trends",
//                         style: TextStyle(fontSize: 12, color: Colors.grey)))
//                 : CustomPaint(painter: _AreaChartPainter(dataPoints)),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- 📋 REPORT CARD UI ---
//   Widget _buildReportCard(
//       BuildContext context, Map<String, dynamic> data, String docId) {
//     DateTime date =
//         (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
//     String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);

//     bool isCompleted = data['isCompleted'] == true;
//     String hbValue = data['hbValue']?.toString() ?? "0.0";
//     String status = data['statusLabel'] ?? "Normal Range";

//     Color themeColor = isCompleted ? Colors.blueAccent : Colors.orangeAccent;
//     if (isCompleted && status.toLowerCase().contains('anemia')) {
//       themeColor = Colors.redAccent;
//     }

//     return GestureDetector(
//       onTap: () {
//         if (!isCompleted) {
//           // ✅ Resume Test Logic
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SymptomQuestionnaireScreen(
//                 reportId: docId,
//                 initialHb: double.tryParse(hbValue) ?? 12.0,
//               ),
//             ),
//           );
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//               color: isCompleted ? Colors.transparent : Colors.orange.shade100),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: 50,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: themeColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15)),
//               child: Icon(
//                   isCompleted
//                       ? Icons.check_circle_outline
//                       : Icons.pending_actions,
//                   color: themeColor),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(formattedDate,
//                       style: const TextStyle(color: Colors.grey, fontSize: 11)),
//                   const SizedBox(height: 4),
//                   Text("$hbValue g/dL",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 18)),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: isCompleted
//                         ? Colors.green.shade50
//                         : Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     isCompleted ? status : "Incomplete",
//                     style: TextStyle(
//                         color: isCompleted ? Colors.green : Colors.orange,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 if (!isCompleted)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 4),
//                     child: Text("Finish Test >",
//                         style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold)),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.folder_open_outlined,
//               size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 15),
//           const Text("No Records Yet",
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey)),
//           const Text("Start your first health checkup now.",
//               style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }

// // Painter class remains the same but with safety checks already handled in build
// class _AreaChartPainter extends CustomPainter {
//   final List<double> points;
//   _AreaChartPainter(this.points);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (points.length < 2) return;

//     final paint = Paint()
//       ..color = Colors.blueAccent
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     final fillPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

//     final path = Path();
//     final fillPath = Path();

//     double dx = size.width / (points.length - 1);
//     double maxY = 18.0;

//     for (int i = 0; i < points.length; i++) {
//       double x = i * dx;
//       double y = size.height - (points[i] / maxY * size.height);

//       if (i == 0) {
//         path.moveTo(x, y);
//         fillPath.moveTo(x, size.height);
//         fillPath.lineTo(x, y);
//       } else {
//         path.lineTo(x, y);
//         fillPath.lineTo(x, y);
//       }
//     }

//     fillPath.lineTo(size.width, size.height);
//     fillPath.close();

//     canvas.drawPath(fillPath, fillPaint);
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
