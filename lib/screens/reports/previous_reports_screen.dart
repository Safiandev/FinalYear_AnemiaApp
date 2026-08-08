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
    final String statusVal = _extractStatus(data);
    final double confidenceVal = _extractConfidence(data);

    final dynamic rawSymptoms = data['symptoms'] ?? data['userSymptoms'] ?? [];
    final List<String> symptomsList = (rawSymptoms is List)
        ? rawSymptoms.map((s) => s.toString()).toList()
        : [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPreviewScreen(
          finalStatus: statusVal,
          finalConfidence: confidenceVal,
          selectedSymptoms: symptomsList,
        ),
      ),
    );
  }

  // ✅ Status ko Firestore document se nikalna (refinedStatus > statusLabel)
  String _extractStatus(Map<String, dynamic> data) {
    return data['refinedStatus']?.toString() ??
        data['statusLabel']?.toString() ??
        'Unknown';
  }

  // ✅ Confidence ko Firestore document se nikalna (refinedConfidence > confidence)
  double _extractConfidence(Map<String, dynamic> data) {
    var raw = data['refinedConfidence'] ?? data['confidence'];
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
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

          double avgConfidence = filteredReports.isNotEmpty
              ? filteredReports
                      .map((r) => _extractConfidence(r))
                      .reduce((a, b) => a + b) /
                  filteredReports.length
              : 0.0;

          int anemicCount = filteredReports
              .where((r) => _extractStatus(r) == 'Anemic')
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterDropdown(),
                const SizedBox(height: 16),
                _buildGraphCard(filteredReports, avgConfidence, anemicCount),
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

  Widget _buildGraphCard(List<Map<String, dynamic>> reports,
      double avgConfidence, int anemicCount) {
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
                  const Text('Average Confidence',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        avgConfidence.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const Text(' %',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: anemicCount > 0
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  anemicCount > 0
                      ? '$anemicCount Anemic Result${anemicCount > 1 ? 's' : ''}'
                      : 'All Normal',
                  style: TextStyle(
                    fontSize: 11,
                    color: anemicCount > 0
                        ? Colors.red.shade700
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
                      minY: 0,
                      maxY: 100,
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
                            reservedSize: 32,
                            interval: 25,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              );
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
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              int idx = spot.x.toInt();
                              String status = (idx >= 0 && idx < reports.length)
                                  ? _extractStatus(reports[idx])
                                  : '';
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(0)}%\n$status',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: reports.asMap().entries.map((e) {
                            return FlSpot(
                                e.key.toDouble(), _extractConfidence(e.value));
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              // ✅ Har point ka color uske status ke hisaab se
                              final bool isAnemicPoint = index >= 0 &&
                                  index < reports.length &&
                                  _extractStatus(reports[index]) == 'Anemic';
                              return FlDotCirclePainter(
                                radius: 4,
                                color:
                                    isAnemicPoint ? Colors.red : Colors.green,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(Colors.red, "Anemic"),
              const SizedBox(width: 20),
              _buildLegendDot(Colors.green, "Non-Anemic"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildReportItemTile(Map<String, dynamic> report) {
    String status = _extractStatus(report);
    double confidence = _extractConfidence(report);
    DateTime date = _parseTimestamp(report['timestamp'] ?? report['createdAt']);
    bool isAnemic = status == 'Anemic';

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
              color: isAnemic ? Colors.red.shade50 : Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAnemic ? Icons.warning_rounded : Icons.check_circle,
              color: isAnemic ? Colors.red.shade400 : Colors.green.shade400,
              size: 20,
            ),
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
                  '${confidence.toStringAsFixed(0)}% Confidence',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAnemic ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                  fontSize: 10,
                  color: isAnemic ? Colors.red.shade700 : Colors.green.shade700,
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
                color: Colors.blue.shade50,
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
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';

// class PreviousReportsScreen extends StatefulWidget {
//   final VoidCallback? onBackToHome;

//   const PreviousReportsScreen({
//     super.key,
//     this.onBackToHome,
//   });

//   @override
//   State<PreviousReportsScreen> createState() => _PreviousReportsScreenState();
// }

// class _PreviousReportsScreenState extends State<PreviousReportsScreen> {
//   String _filterType =
//       'All'; // Options: 'All', '1W', '1M', '3M', 'Custom Date', 'Month & Year'
//   DateTime? _selectedCustomDate;
//   DateTime? _selectedMonthYear;

// // --- DATE PICKER FOR SPECIFIC DATE ---
//   Future<void> _pickCustomDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedCustomDate = picked;
//         _filterType = 'Custom Date';
//       });
//     }
//   }

// // --- MONTH & YEAR PICKER ---
//   Future<void> _pickMonthYear() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDatePickerMode: DatePickerMode.year,
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedMonthYear = picked;
//         _filterType = 'Month & Year';
//       });
//     }
//   }

//   // --- HELPER TO OPEN EXACT SCAN REPORT PDF PREVIEW ---
//   void _openReportPreview(Map<String, dynamic> data) {
//     // 1. Extract Status safely (Anemic / Non-Anemic)
//     final String statusVal = data['statusLabel']?.toString() ?? 'Unknown';

//     // 2. Extract Confidence safely
//     final dynamic rawConfidence =
//         data['refinedConfidence'] ?? data['confidence'] ?? 0.0;
//     final double confidenceVal = (rawConfidence is num)
//         ? rawConfidence.toDouble()
//         : double.tryParse(rawConfidence.toString()) ?? 0.0;

//     // 3. Extract Symptoms safely
//     final dynamic rawSymptoms = data['symptoms'] ?? data['userSymptoms'] ?? [];
//     final List<String> symptomsList = (rawSymptoms is List)
//         ? rawSymptoms.map((s) => s.toString()).toList()
//         : [];

//     // 4. Open ReportPreviewScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReportPreviewScreen(
//           finalStatus: statusVal,
//           finalConfidence: confidenceVal,
//           selectedSymptoms: symptomsList,
//         ),
//       ),
//     );
//   }

//   double _extractHbValue(Map<String, dynamic> data) {
//     var raw = data['hbValue'] ??
//         data['finalHb'] ??
//         data['hb_level'] ??
//         data['hb'] ??
//         data['hemoglobin'] ??
//         data['result'];
//     if (raw == null) return 0.0;
//     return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
//         0.0;
//   }

//   DateTime _parseTimestamp(dynamic rawTimestamp) {
//     if (rawTimestamp is Timestamp) {
//       return rawTimestamp.toDate();
//     } else if (rawTimestamp is int) {
//       return DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
//     } else if (rawTimestamp is String) {
//       return DateTime.tryParse(rawTimestamp) ?? DateTime.now();
//     }
//     return DateTime.now();
//   }

//   // ❌ Purana _filterReports method hata kar is se replace karein:
//   List<Map<String, dynamic>> _filterReports(
//       List<Map<String, dynamic>> rawReports) {
//     if (_filterType == 'All') return rawReports;

//     DateTime now = DateTime.now();

//     return rawReports.where((r) {
//       DateTime reportDate = _parseTimestamp(r['timestamp'] ?? r['createdAt']);

//       if (_filterType == '1W') {
//         return reportDate.isAfter(now.subtract(const Duration(days: 7)));
//       } else if (_filterType == '1M') {
//         return reportDate.isAfter(DateTime(now.year, now.month - 1, now.day));
//       } else if (_filterType == '3M') {
//         return reportDate.isAfter(DateTime(now.year, now.month - 3, now.day));
//       } else if (_filterType == 'Custom Date' && _selectedCustomDate != null) {
//         return reportDate.year == _selectedCustomDate!.year &&
//             reportDate.month == _selectedCustomDate!.month &&
//             reportDate.day == _selectedCustomDate!.day;
//       } else if (_filterType == 'Month & Year' && _selectedMonthYear != null) {
//         return reportDate.year == _selectedMonthYear!.year &&
//             reportDate.month == _selectedMonthYear!.month;
//       }

//       return true;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: Colors.black, size: 20),
//           onPressed: () {
//             if (widget.onBackToHome != null) {
//               widget.onBackToHome!();
//             } else {
//               Navigator.pop(context);
//             }
//           },
//         ),
//         title: const Text(
//           'Health Analytics',
//           style: TextStyle(
//               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('reports')
//             .where('userId', isEqualTo: currentUserId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return _buildEmptyState();
//           }

//           List<Map<String, dynamic>> allReports = snapshot.data!.docs
//               .map((doc) => doc.data() as Map<String, dynamic>)
//               .toList();

//           allReports.sort((a, b) {
//             DateTime tA = _parseTimestamp(a['timestamp'] ?? a['createdAt']);
//             DateTime tB = _parseTimestamp(b['timestamp'] ?? b['createdAt']);
//             return tA.compareTo(tB);
//           });

//           List<Map<String, dynamic>> filteredReports =
//               _filterReports(allReports);
//           List<Map<String, dynamic>> recentList =
//               List.from(filteredReports.reversed);

//           double avgHb = filteredReports.isNotEmpty
//               ? filteredReports
//                       .map((r) => _extractHbValue(r))
//                       .reduce((a, b) => a + b) /
//                   filteredReports.length
//               : 0.0;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildFilterDropdown(),
//                 const SizedBox(height: 16),
//                 _buildGraphCard(filteredReports, avgHb),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Recent Activity',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '${recentList.length} Reports',
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 recentList.isEmpty
//                     ? const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 20),
//                         child: Center(
//                           child: Text(
//                             'No reports found for selected filter duration.',
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: recentList.length,
//                         itemBuilder: (context, index) {
//                           final report = recentList[index];
//                           return _buildReportItemTile(report);
//                         },
//                       ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFilterDropdown() {
//     String displayLabel = _filterType;
//     if (_filterType == 'Custom Date' && _selectedCustomDate != null) {
//       displayLabel = DateFormat('dd MMM yyyy').format(_selectedCustomDate!);
//     } else if (_filterType == 'Month & Year' && _selectedMonthYear != null) {
//       displayLabel = DateFormat('MMMM yyyy').format(_selectedMonthYear!);
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.filter_list, size: 20, color: Colors.blue),
//               const SizedBox(width: 8),
//               Text(
//                 'Filter: $displayLabel',
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//               ),
//             ],
//           ),
//           DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               icon:
//                   const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
//               value: null,
//               hint: const Text('Change',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.blue,
//                       fontWeight: FontWeight.bold)),
//               items: const [
//                 DropdownMenuItem(value: 'All', child: Text('All Reports')),
//                 DropdownMenuItem(value: '1W', child: Text('Last 1 Week')),
//                 DropdownMenuItem(value: '1M', child: Text('Last 1 Month')),
//                 DropdownMenuItem(value: '3M', child: Text('Last 3 Months')),
//                 DropdownMenuItem(
//                     value: 'CUSTOM_DATE',
//                     child: Text('Select Specific Date 📅')),
//                 DropdownMenuItem(
//                     value: 'MONTH_YEAR',
//                     child: Text('Select Month & Year 🗓️')),
//               ],
//               onChanged: (value) {
//                 if (value == 'CUSTOM_DATE') {
//                   _pickCustomDate();
//                 } else if (value == 'MONTH_YEAR') {
//                   _pickMonthYear();
//                 } else if (value != null) {
//                   setState(() {
//                     _filterType = value;
//                     _selectedCustomDate = null;
//                     _selectedMonthYear = null;
//                   });
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGraphCard(List<Map<String, dynamic>> reports, double avgHb) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Average Level',
//                       style: TextStyle(fontSize: 12, color: Colors.grey)),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text(
//                         avgHb.toStringAsFixed(1),
//                         style: const TextStyle(
//                             fontSize: 26, fontWeight: FontWeight.bold),
//                       ),
//                       const Text(' g/dL',
//                           style: TextStyle(color: Colors.grey, fontSize: 14)),
//                     ],
//                   ),
//                 ],
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: avgHb < 12.0
//                       ? Colors.amber.shade50
//                       : Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   avgHb < 12.0 ? 'Attention' : 'Optimal',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: avgHb < 12.0
//                         ? Colors.amber.shade900
//                         : Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 180,
//             child: reports.isEmpty
//                 ? const Center(child: Text("No Data for Chart"))
//                 : LineChart(
//                     LineChartData(
//                       minY: 8.0,
//                       maxY: 18.0,
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: false,
//                         getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey.shade200,
//                           strokeWidth: 1,
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 28,
//                             getTitlesWidget: (value, meta) {
//                               if (value == 8 || value == 12 || value == 16) {
//                                 return Text(
//                                   value.toInt().toString(),
//                                   style: const TextStyle(
//                                       fontSize: 10, color: Colors.grey),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                         ),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             getTitlesWidget: (value, meta) {
//                               int index = value.toInt();
//                               if (index >= 0 && index < reports.length) {
//                                 DateTime d = _parseTimestamp(reports[index]
//                                         ['timestamp'] ??
//                                     reports[index]['createdAt']);
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 4.0),
//                                   child: Text(
//                                     DateFormat('d MMM').format(d),
//                                     style: const TextStyle(
//                                         fontSize: 9, color: Colors.grey),
//                                   ),
//                                 );
//                               }
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                         ),
//                         rightTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                         topTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: reports.asMap().entries.map((e) {
//                             return FlSpot(
//                                 e.key.toDouble(), _extractHbValue(e.value));
//                           }).toList(),
//                           isCurved: true,
//                           color: Colors.blue,
//                           barWidth: 3,
//                           isStrokeCapRound: true,
//                           dotData: FlDotData(show: reports.length < 10),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             color: Colors.blue.withOpacity(0.12),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReportItemTile(Map<String, dynamic> report) {
//     double hb = _extractHbValue(report);
//     DateTime date = _parseTimestamp(report['timestamp'] ?? report['createdAt']);
//     String status = report['status'] ??
//         (hb < 8.0 ? 'Severe' : (hb < 12.0 ? 'Mild Anemia' : 'Normal'));

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.red.shade50,
//               shape: BoxShape.circle,
//             ),
//             child:
//                 Icon(Icons.check_circle, color: Colors.red.shade400, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${DateFormat('MMM dd, yyyy').format(date)}  •  ${DateFormat('hh:mm a').format(date)}',
//                   style: const TextStyle(fontSize: 11, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${hb.toStringAsFixed(1)} g/dL',
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.green.shade700,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//           const SizedBox(width: 8),

//           // DOWNLOAD / VIEW PDF REPORT BUTTON (Triggers ReportPreviewScreen)
//           InkWell(
//             onTap: () => _openReportPreview(report),
//             borderRadius: BorderRadius.circular(10),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50, // Subtle blue background
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.download_rounded, color: Colors.blue, size: 18),
//                   SizedBox(width: 4),
//                   Text(
//                     'PDF',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.assignment_outlined,
//               size: 60, color: Colors.grey.shade400),
//           const SizedBox(height: 10),
//           const Text('No Medical History Found',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 5),
//           const Text('Your completed scan tests will appear here.',
//               style: TextStyle(color: Colors.grey, fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }

