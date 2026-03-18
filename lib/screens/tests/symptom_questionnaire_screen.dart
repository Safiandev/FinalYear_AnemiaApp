import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/tests/ai_refinement_loading_screen.dart';

class SymptomQuestionnaireScreen extends StatefulWidget {
  final double? initialHb;

  const SymptomQuestionnaireScreen({
    super.key,
    this.initialHb,
  });

  @override
  State<SymptomQuestionnaireScreen> createState() =>
      _SymptomQuestionnaireScreenState();
}

class _SymptomQuestionnaireScreenState
    extends State<SymptomQuestionnaireScreen> {
  List<bool> answers = [false, false, false, false, false, false];

  final List<String> questions = [
    "Are you feeling tired?",
    "Do you experience dizziness?",
    "Is your skin unusually pale?",
    "Do you have shortness of breath?",
    "Are your hands or feet cold?",
    "Do you have brittle nails?",
  ];

  // --- CALCULATION LOGIC ---
  double getRefinedResult() {
    double baseHb = widget.initialHb ?? 11.5;
    int selectedCount = answers.where((checked) => checked == true).length;

    // Har symptom par 0.1 reduction (AI Simulation)
    double finalVal = baseHb - (selectedCount * 0.1);
    return double.parse(finalVal.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Clinical Assessment",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROGRESS SECTION (STEP 3) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "STEP 3 OF 4",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  "75%",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 30),

            // --- HEADER TEXT ---
            const Text(
              "Symptom Check",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Select all that apply. Our AI will merge these with your eye-scan for a precise result.",
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 25),

            // --- QUESTIONS LIST ---
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  bool isSelected = answers[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      title: Text(
                        questions[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.blue.shade900
                              : Colors.black87,
                        ),
                      ),
                      value: answers[index],
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onChanged: (val) {
                        setState(() {
                          answers[index] = val!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // --- INFO BOX ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue, size: 24),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Multi-modal refinement increases detection accuracy by 15%.",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- SUBMIT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  double finalResult = getRefinedResult();

                  // 1. Pehle selected symptoms ki list banate hain
                  List<String> selectedSymptoms = [];
                  for (int i = 0; i < questions.length; i++) {
                    if (answers[i] == true) {
                      // Hum list mein wahi sawal add kar rahay hain jo user ne tick kiya
                      selectedSymptoms.add(questions[i]);
                    }
                  }

                  // 2. Ab is list ko agay bhej dete hain
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AiRefinementLoadingScreen(
                        refinedHb: finalResult,
                        selectedSymptoms:
                            selectedSymptoms, // <--- Ab ye error nahi dega!
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Start AI Refinement",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
