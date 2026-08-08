import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;

  // Main Screen State Variables
  String pastIronDiagnosis = "No";
  String bloodGroup = "Not Set";
  String dietPreference = "Omnivore (Regular)";
  String chronicConditions = "None";
  String medications = "None";
  String allergies = "None";
  String doctorNotes = "No notes added";
  String aiStatusText = "Waiting for first scan...";
  String lastUpdatedText = "Never";

  // Options Lists
  final List<String> _bloodGroupOptions = [
    "Not Set",
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];

  final List<String> _dietOptions = [
    "Omnivore (Regular)",
    "Vegetarian",
    "Vegan",
    "Pescatarian"
  ];

  final List<String> _chronicOptions = [
    "None",
    "Thalassemia Trait",
    "Sickle Cell Trait/Disease",
    "Chronic Kidney Disease",
    "Bleeding Disorder",
    "Other (Type manually)"
  ];

  final List<String> _medicationOptions = [
    "None",
    "Iron Supplements",
    "Folic Acid",
    "Vitamin B12",
    "Multivitamins",
    "Other (Type manually)"
  ];

  final List<String> _allergyOptions = [
    "None",
    "Gluten",
    "Dairy",
    "Peanuts",
    "Specific Medicines",
    "Other (Type manually)"
  ];

  // Text Controllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customMedsController = TextEditingController();
  final TextEditingController _customAllergiesController =
      TextEditingController();
  final TextEditingController _customChronicController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customMedsController.dispose();
    _customAllergiesController.dispose();
    _customChronicController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicalData() async {
    try {
      String uid = _auth.currentUser?.uid ?? "";
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Load Scan Insight if available
        if (data.containsKey('last_scan_status')) {
          aiStatusText =
              data['last_scan_status'] ?? "Waiting for first scan...";
        }

        if (data.containsKey('medical_history')) {
          var history = data['medical_history'];
          setState(() {
            pastIronDiagnosis = history['iron_deficiency'] ?? "No";
            bloodGroup = history['blood_group'] ?? "Not Set";
            dietPreference = history['diet_preference'] ?? "Omnivore (Regular)";
            chronicConditions = history['chronic_conditions'] ?? "None";
            medications = history['medications'] ?? "None";
            allergies = history['allergies'] ?? "None";
            doctorNotes = history['doctor_notes'] ?? "No notes added";
            lastUpdatedText = history['last_updated'] ?? "Never";

            _notesController.text =
                doctorNotes == "No notes added" ? "" : doctorNotes;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Medical Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("AI HEALTH INSIGHTS"),
                  const SizedBox(height: 10),
                  aiStatusCard(
                      "CURRENT STATUS", aiStatusText, Icons.auto_awesome),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader("MEDICAL PROFILE"),
                      InkWell(
                        onTap: _showEditSheet,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.edit_note,
                                  size: 18, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  historyCard(
                    "Past Iron Deficiency Diagnosis",
                    pastIronDiagnosis,
                    Icons.history_edu,
                    pastIronDiagnosis == "Yes"
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                  ),
                  historyCard(
                    "Blood Group",
                    bloodGroup,
                    Icons.water_drop_outlined,
                    const Color(0xFFEC4899),
                  ),
                  historyCard(
                    "Dietary Preference",
                    dietPreference,
                    Icons.restaurant,
                    const Color(0xFF10B981),
                  ),
                  historyCard(
                    "Chronic Medical Conditions",
                    chronicConditions,
                    Icons.healing_outlined,
                    const Color(0xFFF97316),
                  ),
                  historyCard(
                    "Current Medications",
                    medications,
                    Icons.medication_outlined,
                    const Color(0xFF8B5CF6),
                  ),
                  historyCard(
                    "Known Allergies",
                    allergies,
                    Icons.warning_amber_rounded,
                    const Color(0xFFEAB308),
                  ),
                  historyCard(
                    "Doctor Notes & Remarks",
                    doctorNotes,
                    Icons.notes_outlined,
                    const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 20),
                  _buildTipCard(),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Last Updated: $lastUpdatedText",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ---------- EDIT BOTTOM SHEET MODAL ----------

  void _showEditSheet() {
    String tempIron = pastIronDiagnosis;
    String tempBlood = bloodGroup;
    String tempDiet = _dietOptions.contains(dietPreference)
        ? dietPreference
        : _dietOptions[0];

    String tempChronic = _chronicOptions.contains(chronicConditions)
        ? chronicConditions
        : "Other (Type manually)";

    String tempMeds = _medicationOptions.contains(medications)
        ? medications
        : "Other (Type manually)";

    String tempAllergy = _allergyOptions.contains(allergies)
        ? allergies
        : "Other (Type manually)";

    _customChronicController.text =
        tempChronic == "Other (Type manually)" ? chronicConditions : "";
    _customMedsController.text =
        tempMeds == "Other (Type manually)" ? medications : "";
    _customAllergiesController.text =
        tempAllergy == "Other (Type manually)" ? allergies : "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Update Medical Profile",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 18),

                // Diagnosis Switch
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      "Diagnosed with Iron Deficiency?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text(
                      tempIron == "Yes"
                          ? "Yes (Doctor/Lab diagnosed)"
                          : "No (No past history)",
                      style: TextStyle(
                        color: tempIron == "Yes"
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF16A34A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: tempIron == "Yes",
                    activeThumbColor: const Color(0xFF2563EB),
                    onChanged: (val) =>
                        setSheetState(() => tempIron = val ? "Yes" : "No"),
                  ),
                ),
                const SizedBox(height: 14),

                _buildDropdown("Blood Group", _bloodGroupOptions, tempBlood,
                    (val) {
                  setSheetState(() => tempBlood = val!);
                }),

                _buildDropdown("Dietary Preference", _dietOptions, tempDiet,
                    (val) {
                  setSheetState(() => tempDiet = val!);
                }),

                _buildDropdown(
                    "Chronic Medical Conditions", _chronicOptions, tempChronic,
                    (val) {
                  setSheetState(() => tempChronic = val!);
                }),
                if (tempChronic == "Other (Type manually)")
                  _buildInputField(_customChronicController,
                      "Specify Condition", Icons.healing_outlined),

                _buildDropdown(
                    "Current Medication", _medicationOptions, tempMeds, (val) {
                  setSheetState(() => tempMeds = val!);
                }),
                if (tempMeds == "Other (Type manually)")
                  _buildInputField(_customMedsController, "Specify Medication",
                      Icons.medication_liquid_outlined),

                _buildDropdown("Known Allergies", _allergyOptions, tempAllergy,
                    (val) {
                  setSheetState(() => tempAllergy = val!);
                }),
                if (tempAllergy == "Other (Type manually)")
                  _buildInputField(_customAllergiesController,
                      "Specify Allergy", Icons.warning_amber_outlined),

                _buildInputField(
                  _notesController,
                  "Additional Doctor Notes / Instructions",
                  Icons.notes_outlined,
                  lines: 3,
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setSheetState(() => _isSaving = true);

                            try {
                              String finalChronic =
                                  (tempChronic == "Other (Type manually)")
                                      ? _customChronicController.text
                                      : tempChronic;
                              String finalMeds =
                                  (tempMeds == "Other (Type manually)")
                                      ? _customMedsController.text
                                      : tempMeds;
                              String finalAllergy =
                                  (tempAllergy == "Other (Type manually)")
                                      ? _customAllergiesController.text
                                      : tempAllergy;

                              DateTime now = DateTime.now();
                              String formattedDate =
                                  "${now.day} ${_getMonthName(now.month)} ${now.year}";

                              await _firestore
                                  .collection('users')
                                  .doc(_auth.currentUser!.uid)
                                  .set({
                                'medical_history': {
                                  'iron_deficiency': tempIron,
                                  'blood_group': tempBlood,
                                  'diet_preference': tempDiet,
                                  'chronic_conditions': finalChronic.isEmpty
                                      ? "None"
                                      : finalChronic,
                                  'medications':
                                      finalMeds.isEmpty ? "None" : finalMeds,
                                  'allergies': finalAllergy.isEmpty
                                      ? "None"
                                      : finalAllergy,
                                  'doctor_notes':
                                      _notesController.text.trim().isEmpty
                                          ? "No notes added"
                                          : _notesController.text.trim(),
                                  'last_updated': formattedDate,
                                }
                              }, SetOptions(merge: true));

                              setState(() {
                                pastIronDiagnosis = tempIron;
                                bloodGroup = tempBlood;
                                dietPreference = tempDiet;
                                chronicConditions = finalChronic.isEmpty
                                    ? "None"
                                    : finalChronic;
                                medications =
                                    finalMeds.isEmpty ? "None" : finalMeds;
                                allergies = finalAllergy.isEmpty
                                    ? "None"
                                    : finalAllergy;
                                doctorNotes =
                                    _notesController.text.trim().isEmpty
                                        ? "No notes added"
                                        : _notesController.text.trim();
                                lastUpdatedText = formattedDate;
                              });

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Medical Profile Updated Successfully!",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint("Save error: $e");
                            } finally {
                              setSheetState(() => _isSaving = false);
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Save Profile Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HELPER & UI BUILDERS ----------

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String currentVal,
    Function(String?) onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(currentVal) ? currentVal : options[0],
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChange,
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: lines,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget aiStatusCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget historyCard(
      String title, String value, IconData icon, Color accentColor) {
    bool isDefaultValue = (value == "Not Set" ||
        value == "None" ||
        value == "No" ||
        value == "No notes added");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: isDefaultValue
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                    fontWeight:
                        isDefaultValue ? FontWeight.w500 : FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates_outlined,
              color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "HemoGlobe AI uses your diet and medical history to tailor non-invasive anemia risk assessments.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class MedicalHistoryScreen extends StatefulWidget {
//   const MedicalHistoryScreen({super.key});

//   @override
//   State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
// }

// class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool _isLoading = true;
//   bool _isSaving = false;

//   // Main Screen State Variables
//   String pastIronDiagnosis = "No";
//   String bloodGroup = "Not Set";
//   String dietPreference = "Omnivore (Regular)";
//   String chronicConditions = "None";
//   String medications = "None";
//   String allergies = "None";
//   String doctorNotes = "No notes added";
//   String aiStatusText = "Waiting for first scan...";
//   String lastUpdatedText = "Never";

//   // Options Lists
//   final List<String> _bloodGroupOptions = [
//     "Not Set",
//     "A+",
//     "A-",
//     "B+",
//     "B-",
//     "O+",
//     "O-",
//     "AB+",
//     "AB-"
//   ];

//   final List<String> _dietOptions = [
//     "Omnivore (Regular)",
//     "Vegetarian",
//     "Vegan",
//     "Pescatarian"
//   ];

//   final List<String> _chronicOptions = [
//     "None",
//     "Thalassemia Trait",
//     "Sickle Cell Trait/Disease",
//     "Chronic Kidney Disease",
//     "Bleeding Disorder",
//     "Other (Type manually)"
//   ];

//   final List<String> _medicationOptions = [
//     "None",
//     "Iron Supplements",
//     "Folic Acid",
//     "Vitamin B12",
//     "Multivitamins",
//     "Other (Type manually)"
//   ];

//   final List<String> _allergyOptions = [
//     "None",
//     "Gluten",
//     "Dairy",
//     "Peanuts",
//     "Specific Medicines",
//     "Other (Type manually)"
//   ];

//   // Text Controllers
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _customMedsController = TextEditingController();
//   final TextEditingController _customAllergiesController =
//       TextEditingController();
//   final TextEditingController _customChronicController =
//       TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchMedicalData();
//   }

//   @override
//   void dispose() {
//     _notesController.dispose();
//     _customMedsController.dispose();
//     _customAllergiesController.dispose();
//     _customChronicController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchMedicalData() async {
//     try {
//       String uid = _auth.currentUser?.uid ?? "";
//       DocumentSnapshot doc =
//           await _firestore.collection('users').doc(uid).get();

//       if (doc.exists && doc.data() != null) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//         // Load Scan Insight if available
//         if (data.containsKey('last_scan_status')) {
//           aiStatusText =
//               data['last_scan_status'] ?? "Waiting for first scan...";
//         }

//         if (data.containsKey('medical_history')) {
//           var history = data['medical_history'];
//           setState(() {
//             pastIronDiagnosis = history['iron_deficiency'] ?? "No";
//             bloodGroup = history['blood_group'] ?? "Not Set";
//             dietPreference = history['diet_preference'] ?? "Omnivore (Regular)";
//             chronicConditions = history['chronic_conditions'] ?? "None";
//             medications = history['medications'] ?? "None";
//             allergies = history['allergies'] ?? "None";
//             doctorNotes = history['doctor_notes'] ?? "No notes added";
//             lastUpdatedText = history['last_updated'] ?? "Never";

//             _notesController.text =
//                 doctorNotes == "No notes added" ? "" : doctorNotes;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Fetch Error: $e");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text(
//           "Medical Profile",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black87),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _sectionHeader("AI Health Insights"),
//                   const SizedBox(height: 8),
//                   aiStatusCard(
//                       "Current Status", aiStatusText, Icons.auto_awesome),
//                   const SizedBox(height: 22),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _sectionHeader("Medical Profile"),
//                       TextButton.icon(
//                         onPressed: _showEditSheet,
//                         icon: const Icon(Icons.edit_note,
//                             size: 20, color: Colors.indigo),
//                         label: const Text(
//                           "Edit Profile",
//                           style: TextStyle(
//                             color: Colors.indigo,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   historyCard(
//                     "Past Iron Deficiency Diagnosis",
//                     pastIronDiagnosis,
//                     Icons.history_edu,
//                     pastIronDiagnosis == "Yes"
//                         ? Colors.red.shade400
//                         : Colors.indigo.shade400,
//                   ),
//                   historyCard(
//                     "Blood Group",
//                     bloodGroup,
//                     Icons.water_drop,
//                     Colors.pink.shade400,
//                   ),
//                   historyCard(
//                     "Dietary Preference",
//                     dietPreference,
//                     Icons.restaurant_menu,
//                     Colors.teal.shade400,
//                   ),
//                   historyCard(
//                     "Chronic Medical Conditions",
//                     chronicConditions,
//                     Icons.healing,
//                     Colors.deepOrange.shade400,
//                   ),
//                   historyCard(
//                     "Current Medications",
//                     medications,
//                     Icons.medication,
//                     Colors.green.shade400,
//                   ),
//                   historyCard(
//                     "Known Allergies",
//                     allergies,
//                     Icons.warning_amber_rounded,
//                     Colors.amber.shade700,
//                   ),
//                   historyCard(
//                     "Doctor Notes & Remarks",
//                     doctorNotes,
//                     Icons.notes,
//                     Colors.blueGrey.shade400,
//                   ),
//                   const SizedBox(height: 20),
//                   _buildTipCard(),
//                   const SizedBox(height: 12),
//                   Center(
//                     child: Text(
//                       "Last Updated: $lastUpdatedText",
//                       style:
//                           TextStyle(fontSize: 11, color: Colors.grey.shade500),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//     );
//   }

//   // ---------- EDIT BOTTOM SHEET MODAL ----------

//   void _showEditSheet() {
//     String tempIron = pastIronDiagnosis;
//     String tempBlood = bloodGroup;
//     String tempDiet = _dietOptions.contains(dietPreference)
//         ? dietPreference
//         : _dietOptions[0];

//     String tempChronic = _chronicOptions.contains(chronicConditions)
//         ? chronicConditions
//         : "Other (Type manually)";

//     String tempMeds = _medicationOptions.contains(medications)
//         ? medications
//         : "Other (Type manually)";

//     String tempAllergy = _allergyOptions.contains(allergies)
//         ? allergies
//         : "Other (Type manually)";

//     _customChronicController.text =
//         tempChronic == "Other (Type manually)" ? chronicConditions : "";
//     _customMedsController.text =
//         tempMeds == "Other (Type manually)" ? medications : "";
//     _customAllergiesController.text =
//         tempAllergy == "Other (Type manually)" ? allergies : "";

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => StatefulBuilder(
//         builder: (context, setSheetState) => Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//             left: 20,
//             right: 20,
//             top: 14,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 42,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 const Text(
//                   "Update Medical Profile",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),

//                 // Diagnosis Switch
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8F9FA),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: SwitchListTile(
//                     title: const Text(
//                       "Previously Diagnosed with Iron Deficiency?",
//                       style:
//                           TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       tempIron == "Yes"
//                           ? "Yes (Doctor/Lab diagnosed)"
//                           : "No (No past history)",
//                       style: TextStyle(
//                         color: tempIron == "Yes"
//                             ? Colors.red
//                             : Colors.green.shade700,
//                         fontSize: 11,
//                       ),
//                     ),
//                     value: tempIron == "Yes",
//                     activeColor: Colors.indigo,
//                     onChanged: (val) =>
//                         setSheetState(() => tempIron = val ? "Yes" : "No"),
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 _buildDropdown("Blood Group", _bloodGroupOptions, tempBlood,
//                     (val) {
//                   setSheetState(() => tempBlood = val!);
//                 }),

//                 _buildDropdown("Dietary Preference", _dietOptions, tempDiet,
//                     (val) {
//                   setSheetState(() => tempDiet = val!);
//                 }),

//                 _buildDropdown(
//                     "Chronic Medical Conditions", _chronicOptions, tempChronic,
//                     (val) {
//                   setSheetState(() => tempChronic = val!);
//                 }),
//                 if (tempChronic == "Other (Type manually)")
//                   _buildInputField(_customChronicController,
//                       "Specify Condition", Icons.healing),

//                 _buildDropdown(
//                     "Current Medication", _medicationOptions, tempMeds, (val) {
//                   setSheetState(() => tempMeds = val!);
//                 }),
//                 if (tempMeds == "Other (Type manually)")
//                   _buildInputField(_customMedsController, "Specify Medication",
//                       Icons.medication_liquid),

//                 _buildDropdown("Known Allergies", _allergyOptions, tempAllergy,
//                     (val) {
//                   setSheetState(() => tempAllergy = val!);
//                 }),
//                 if (tempAllergy == "Other (Type manually)")
//                   _buildInputField(_customAllergiesController,
//                       "Specify Allergy", Icons.warning_amber),

//                 _buildInputField(
//                   _notesController,
//                   "Additional Doctor Notes / Instructions",
//                   Icons.notes,
//                   lines: 2,
//                 ),

//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.indigo,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: _isSaving
//                         ? null
//                         : () async {
//                             setSheetState(() => _isSaving = true);

//                             try {
//                               String finalChronic =
//                                   (tempChronic == "Other (Type manually)")
//                                       ? _customChronicController.text
//                                       : tempChronic;
//                               String finalMeds =
//                                   (tempMeds == "Other (Type manually)")
//                                       ? _customMedsController.text
//                                       : tempMeds;
//                               String finalAllergy =
//                                   (tempAllergy == "Other (Type manually)")
//                                       ? _customAllergiesController.text
//                                       : tempAllergy;

//                               DateTime now = DateTime.now();
//                               String formattedDate =
//                                   "${now.day} ${_getMonthName(now.month)} ${now.year}";

//                               await _firestore
//                                   .collection('users')
//                                   .doc(_auth.currentUser!.uid)
//                                   .set({
//                                 'medical_history': {
//                                   'iron_deficiency': tempIron,
//                                   'blood_group': tempBlood,
//                                   'diet_preference': tempDiet,
//                                   'chronic_conditions': finalChronic.isEmpty
//                                       ? "None"
//                                       : finalChronic,
//                                   'medications':
//                                       finalMeds.isEmpty ? "None" : finalMeds,
//                                   'allergies': finalAllergy.isEmpty
//                                       ? "None"
//                                       : finalAllergy,
//                                   'doctor_notes':
//                                       _notesController.text.trim().isEmpty
//                                           ? "No notes added"
//                                           : _notesController.text.trim(),
//                                   'last_updated': formattedDate,
//                                 }
//                               }, SetOptions(merge: true));

//                               setState(() {
//                                 pastIronDiagnosis = tempIron;
//                                 bloodGroup = tempBlood;
//                                 dietPreference = tempDiet;
//                                 chronicConditions = finalChronic.isEmpty
//                                     ? "None"
//                                     : finalChronic;
//                                 medications =
//                                     finalMeds.isEmpty ? "None" : finalMeds;
//                                 allergies = finalAllergy.isEmpty
//                                     ? "None"
//                                     : finalAllergy;
//                                 doctorNotes =
//                                     _notesController.text.trim().isEmpty
//                                         ? "No notes added"
//                                         : _notesController.text.trim();
//                                 lastUpdatedText = formattedDate;
//                               });

//                               if (mounted) {
//                                 Navigator.pop(context);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text("Medical Profile Updated!"),
//                                     backgroundColor: Colors.green,
//                                     behavior: SnackBarBehavior.floating,
//                                   ),
//                                 );
//                               }
//                             } catch (e) {
//                               debugPrint("Save error: $e");
//                             } finally {
//                               setSheetState(() => _isSaving = false);
//                             }
//                           },
//                     child: _isSaving
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                                 color: Colors.white, strokeWidth: 2))
//                         : const Text(
//                             "Save Profile Changes",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------- HELPER & UI BUILDERS ----------

//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return months[month - 1];
//   }

//   Widget _buildDropdown(
//     String label,
//     List<String> options,
//     String currentVal,
//     Function(String?) onChange,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: DropdownButtonFormField<String>(
//         value: options.contains(currentVal) ? currentVal : options[0],
//         style: const TextStyle(fontSize: 13, color: Colors.black87),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//           filled: true,
//           fillColor: const Color(0xFFF8F9FA),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
//           ),
//         ),
//         items: options
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: onChange,
//       ),
//     );
//   }

//   Widget _buildInputField(
//     TextEditingController controller,
//     String label,
//     IconData icon, {
//     int lines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextField(
//         controller: controller,
//         maxLines: lines,
//         style: const TextStyle(fontSize: 13, color: Colors.black87),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//           prefixIcon: Icon(icon, size: 18, color: Colors.indigo.shade400),
//           filled: true,
//           fillColor: const Color(0xFFF8F9FA),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget aiStatusCard(String title, String value, IconData icon) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.indigo.shade800, Colors.indigo.shade500],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.indigo.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white, size: 26),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.8,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget historyCard(
//       String title, String value, IconData icon, Color accentColor) {
//     bool isDefaultValue = (value == "Not Set" ||
//         value == "None" ||
//         value == "No" ||
//         value == "No notes added");

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.015),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 18,
//             backgroundColor: accentColor.withOpacity(0.12),
//             child: Icon(icon, color: accentColor, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     color: isDefaultValue
//                         ? Colors.grey.shade500
//                         : Colors.indigo.shade900,
//                     fontWeight:
//                         isDefaultValue ? FontWeight.normal : FontWeight.w600,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 2),
//       child: Text(
//         title.toUpperCase(),
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey.shade600,
//           letterSpacing: 1.0,
//         ),
//       ),
//     );
//   }

//   Widget _buildTipCard() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.indigo.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.indigo.withOpacity(0.1)),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.tips_and_updates_outlined, color: Colors.indigo, size: 18),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "HemoGlobe AI uses your diet and medical history to tailor non-invasive anemia risk assessments.",
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.indigo,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

