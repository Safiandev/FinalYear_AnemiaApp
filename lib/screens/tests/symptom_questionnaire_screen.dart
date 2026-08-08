import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/tests/ai_refinement_loading_screen.dart';

class SymptomQuestionnaireScreen extends StatefulWidget {
  final String reportId; // ✅ Firestore document ID passed from scan screen
  final String initialStatus; // "Anemic" or "Non-Anemic"
  final double initialConfidence; // 0-100

  const SymptomQuestionnaireScreen({
    super.key,
    required this.reportId,
    required this.initialStatus,
    required this.initialConfidence,
  });

  @override
  State<SymptomQuestionnaireScreen> createState() =>
      _SymptomQuestionnaireScreenState();
}

class _SymptomQuestionnaireScreenState
    extends State<SymptomQuestionnaireScreen> {
  // ✅ Dynamic symptoms structure with icons for clean visual presentation
  final List<Map<String, dynamic>> _symptoms = [
    {
      "title": "Feeling Tired / Fatigue",
      "subtitle": "Unusual exhaustion or low energy levels",
      "icon": Icons.battery_alert_rounded,
      "isSelected": false,
    },
    {
      "title": "Dizziness or Lightheadedness",
      "subtitle": "Feeling faint, unstable, or unsteady",
      "icon": Icons.blur_on_rounded,
      "isSelected": false,
    },
    {
      "title": "Pale or Yellowish Skin",
      "subtitle": "Noticeable lack of natural skin warmth/color",
      "icon": Icons.face_retouching_natural_rounded,
      "isSelected": false,
    },
    {
      "title": "Shortness of Breath",
      "subtitle": "Difficulty breathing during routine activities",
      "icon": Icons.air_rounded,
      "isSelected": false,
    },
    {
      "title": "Cold Hands or Feet",
      "subtitle": "Unusual chillness in outer extremities",
      "icon": Icons.ac_unit_rounded,
      "isSelected": false,
    },
    {
      "title": "Brittle Nails / Hair Loss",
      "subtitle": "Noticeable fragility in nails or hair thinning",
      "icon": Icons.content_cut_rounded,
      "isSelected": false,
    },
  ];

  bool _isSaving = false;

  // --- LOGIC: SYMPTOM-BASED CONFIDENCE REFINEMENT ---
  // Har symptom, model ke confidence ko us status ki taraf thoda shift karta hai
  Map<String, dynamic> _getRefinedResult() {
    int selectedCount = _symptoms.where((s) => s['isSelected'] == true).length;
    double baseConfidence = widget.initialConfidence;
    String refinedStatus = widget.initialStatus;

    // Har symptom 3% weight adjust karta hai (clinical risk factor)
    double adjustment = selectedCount * 3.0;

    if (widget.initialStatus == 'Anemic') {
      // Symptoms mojood hain to confidence barhta hai (max 99%)
      baseConfidence = (baseConfidence + adjustment).clamp(0.0, 99.0);
    } else {
      // Non-Anemic tha lekin symptoms mil rahe hain -> confidence kam hota hai
      baseConfidence = (baseConfidence - adjustment).clamp(1.0, 100.0);

      // Agar bohot zyada symptoms hain (4+) to status hi flip kar dein
      if (selectedCount >= 4 && baseConfidence < 50) {
        refinedStatus = 'Anemic';
        baseConfidence = 100 - baseConfidence; // confidence ab Anemic ki taraf
      }
    }

    return {
      'status': refinedStatus,
      'confidence': double.parse(baseConfidence.toStringAsFixed(1)),
    };
  }

  Future<void> _processAndNavigate() async {
    setState(() => _isSaving = true);

    Map<String, dynamic> refinedResult = _getRefinedResult();
    String refinedStatus = refinedResult['status'];
    double refinedConfidence = refinedResult['confidence'];

    // Selected symptoms filter
    List<String> selectedSymptoms = _symptoms
        .where((s) => s['isSelected'] == true)
        .map((s) => s['title'] as String)
        .toList();

    try {
      // 1. Update Firestore Report with Selected Symptoms
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .set({
        'symptoms': selectedSymptoms,
        'symptomCount': selectedSymptoms.length,
        'refinedStatus': refinedStatus,
        'refinedConfidence': refinedConfidence,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // 2. Navigate to AI Refinement Loading Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiRefinementLoadingScreen(
            refinedStatus: refinedStatus,
            refinedConfidence: refinedConfidence,
            selectedSymptoms: selectedSymptoms,
            reportId: widget.reportId,
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error updating symptoms in Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving questionnaire: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = _symptoms.where((s) => s['isSelected'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Clinical Assessment",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PROGRESS BAR SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "STEP 3 OF 4",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.1,
                      fontSize: 11,
                    ),
                  ),
                  const Text(
                    "75%",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),

              // --- HEADER TEXT ---
              const Text(
                "Symptom Checklist",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Select all symptoms you are currently experiencing. Our AI engine integrates these with your optical scan.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // --- DYNAMIC SYMPTOMS LIST ---
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _symptoms.length,
                  itemBuilder: (context, index) {
                    final item = _symptoms[index];
                    final bool isSelected = item['isSelected'];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade50.withValues(alpha: 0.6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade200,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            item['isSelected'] = !isSelected;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Icon avatar container
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.blue.shade800
                                      : Colors.grey.shade600,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Text titles
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.blue.shade900
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitle'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Custom checkbox tick
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                    width: 1.8,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // --- AI INFO BADGE ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Multi-modal fusion adjusts hemoglobin estimates using weighted clinical risk indices.",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- SUBMIT / ACTION BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSaving ? null : _processAndNavigate,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedCount > 0
                                  ? "Analyze with $selectedCount Symptom${selectedCount > 1 ? 's' : ''}"
                                  : "Proceed Without Symptoms",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:hemoglobe_ai/screens/tests/ai_refinement_loading_screen.dart';

// class SymptomQuestionnaireScreen extends StatefulWidget {
//   final String reportId; // ✅ Removed optional mark, logic requires this ID
//   final double initialHb;

//   const SymptomQuestionnaireScreen({
//     super.key,
//     required this.reportId, // ✅ Must be passed from Scan screen
//     required this.initialHb,
//   });

//   @override
//   State<SymptomQuestionnaireScreen> createState() =>
//       _SymptomQuestionnaireScreenState();
// }

// class _SymptomQuestionnaireScreenState
//     extends State<SymptomQuestionnaireScreen> {
//   // Answers list
//   List<bool> answers = [false, false, false, false, false, false];

//   // Questions list
//   final List<String> questions = [
//     "Are you feeling tired?",
//     "Do you experience dizziness?",
//     "Is your skin unusually pale?",
//     "Do you have shortness of breath?",
//     "Are your hands or feet cold?",
//     "Do you have brittle nails?",
//   ];

//   // --- LOGIC: CALCULATION ---
//   double getRefinedResult() {
//     double baseHb = widget.initialHb;
//     int selectedCount = answers.where((checked) => checked == true).length;

//     // Har symptom par 0.1 reduction (AI Simulation)
//     // Safian, yahan hum base Hb se symptoms ke mutabiq value refine kar rahe hain
//     double finalVal = baseHb - (selectedCount * 0.1);

//     // Safety check taake Hb negative na jaye (physically impossible)
//     if (finalVal < 2.0) finalVal = 2.0;

//     return double.parse(finalVal.toStringAsFixed(1));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Clinical Assessment",
//           style: TextStyle(
//               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- PROGRESS SECTION ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "STEP 3 OF 4",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                     letterSpacing: 1.2,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const Text(
//                   "75%",
//                   style: TextStyle(
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: 0.75,
//                 backgroundColor: Colors.grey.shade200,
//                 color: Colors.blue,
//                 minHeight: 8,
//               ),
//             ),
//             const SizedBox(height: 30),

//             // --- HEADER ---
//             const Text(
//               "Symptom Check",
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Select all that apply. Our AI will merge these with your eye-scan for a precise result.",
//               style: TextStyle(
//                   color: Colors.grey.shade600, fontSize: 14, height: 1.4),
//             ),
//             const SizedBox(height: 25),

//             // --- QUESTIONS LIST ---
//             Expanded(
//               child: ListView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   bool isSelected = answers[index];
//                   return AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: const EdgeInsets.only(bottom: 12),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Colors.blue.withOpacity(0.05)
//                           : Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(
//                         color: isSelected ? Colors.blue : Colors.grey.shade300,
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: CheckboxListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 15, vertical: 5),
//                       title: Text(
//                         questions[index],
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight:
//                               isSelected ? FontWeight.bold : FontWeight.normal,
//                           color: isSelected
//                               ? Colors.blue.shade900
//                               : Colors.black87,
//                         ),
//                       ),
//                       value: answers[index],
//                       activeColor: Colors.blue,
//                       checkColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5)),
//                       onChanged: (val) {
//                         setState(() {
//                           answers[index] = val!;
//                         });
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // --- INFO BOX ---
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.auto_awesome, color: Colors.blue, size: 24),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: Text(
//                       "Multi-modal refinement increases detection accuracy by 15%.",
//                       style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // --- SUBMIT BUTTON ---
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 onPressed: () {
//                   double finalResult = getRefinedResult();

//                   // 1. Filter selected symptoms
//                   List<String> selectedSymptoms = [];
//                   for (int i = 0; i < questions.length; i++) {
//                     if (answers[i] == true) {
//                       selectedSymptoms.add(questions[i]);
//                     }
//                   }

//                   // 2. Navigate with Data
//                   // ✅ Passing the same reportId to prevent duplicates
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AiRefinementLoadingScreen(
//                         refinedHb: finalResult,
//                         selectedSymptoms: selectedSymptoms,
//                         reportId: widget.reportId,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Start AI Refinement",
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                     SizedBox(width: 10),
//                     Icon(Icons.arrow_forward_rounded, color: Colors.white),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
