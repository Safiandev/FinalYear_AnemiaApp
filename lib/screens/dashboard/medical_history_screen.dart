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

  // Main Screen Variables
  String ironDeficiency = "No";
  String bloodGroup = "Not Set";
  String medications = "None";
  String allergies = "None";
  String doctorNotes = "No notes added";

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

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customMedsController = TextEditingController();
  final TextEditingController _customAllergiesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  Future<void> _fetchMedicalData() async {
    try {
      String uid = _auth.currentUser?.uid ?? "";
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('medical_history')) {
          var history = data['medical_history'];
          setState(() {
            ironDeficiency = history['iron_deficiency'] ?? "No";
            bloodGroup = history['blood_group'] ?? "Not Set";
            medications = history['medications'] ?? "None";
            allergies = history['allergies'] ?? "None";
            doctorNotes = history['doctor_notes'] ?? "No notes added";
            _notesController.text =
                doctorNotes == "No notes added" ? "" : doctorNotes;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Medical Profile",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("AI Health Insights"),
                  const SizedBox(height: 10),
                  autoUpdateCard("Current Status", "Waiting for first scan...",
                      Icons.auto_awesome),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader("Medical Profile (Manual)"),
                      TextButton.icon(
                        onPressed: _showEditSheet,
                        icon: const Icon(Icons.edit_note,
                            size: 20, color: Colors.blue),
                        label: const Text("Edit Profile",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  historyCard("Iron Deficient", ironDeficiency, Icons.bloodtype,
                      Colors.red),
                  historyCard(
                      "Blood Group", bloodGroup, Icons.water_drop, Colors.pink),
                  historyCard("Medication", medications, Icons.medication,
                      Colors.green),
                  historyCard("Allergies", allergies,
                      Icons.warning_amber_rounded, Colors.orange),
                  historyCard("Doctor Notes", doctorNotes, Icons.notes,
                      Colors.blueGrey),
                  const SizedBox(height: 30),
                  _buildTipCard(),
                ],
              ),
            ),
    );
  }

  void _showEditSheet() {
    // Temporary variables to prevent immediate update on main screen
    String tempIron = ironDeficiency;
    String tempBlood = bloodGroup;
    String tempMeds = _medicationOptions.contains(medications)
        ? medications
        : "Other (Type manually)";
    String tempAllergy = _allergyOptions.contains(allergies)
        ? allergies
        : "Other (Type manually)";

    _customMedsController.text =
        tempMeds == "Other (Type manually)" ? medications : "";
    _customAllergiesController.text =
        tempAllergy == "Other (Type manually)" ? allergies : "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 15,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("Update Medical Info",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Are you Iron Deficient?",
                      style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                      tempIron == "Yes" ? "Status: Yes" : "Status: No",
                      style: TextStyle(
                          color: tempIron == "Yes" ? Colors.red : Colors.green,
                          fontSize: 12)),
                  value: tempIron == "Yes",
                  onChanged: (val) =>
                      setSheetState(() => tempIron = val ? "Yes" : "No"),
                ),
                _buildDropdown(
                    "Blood Group",
                    [
                      "Not Set",
                      "A+",
                      "A-",
                      "B+",
                      "B-",
                      "O+",
                      "O-",
                      "AB+",
                      "AB-"
                    ],
                    tempBlood, (val) {
                  setSheetState(() => tempBlood = val!);
                }),
                _buildDropdown(
                    "Current Medication", _medicationOptions, tempMeds, (val) {
                  setSheetState(() => tempMeds = val!);
                }),
                if (tempMeds == "Other (Type manually)")
                  _buildInputField(_customMedsController,
                      "Type Medication Name", Icons.medication_liquid),
                _buildDropdown("Known Allergies", _allergyOptions, tempAllergy,
                    (val) {
                  setSheetState(() => tempAllergy = val!);
                }),
                if (tempAllergy == "Other (Type manually)")
                  _buildInputField(_customAllergiesController,
                      "Type Allergy Name", Icons.warning_amber),
                _buildInputField(
                    _notesController, "Additional Notes", Icons.notes,
                    lines: 2),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setSheetState(() =>
                                _isSaving = true); // Start Loading in Sheet

                            try {
                              String finalMeds =
                                  (tempMeds == "Other (Type manually)")
                                      ? _customMedsController.text
                                      : tempMeds;
                              String finalAllergy =
                                  (tempAllergy == "Other (Type manually)")
                                      ? _customAllergiesController.text
                                      : tempAllergy;

                              await _firestore
                                  .collection('users')
                                  .doc(_auth.currentUser!.uid)
                                  .update({
                                'medical_history': {
                                  'iron_deficiency': tempIron,
                                  'blood_group': tempBlood,
                                  'medications':
                                      finalMeds.isEmpty ? "None" : finalMeds,
                                  'allergies': finalAllergy.isEmpty
                                      ? "None"
                                      : finalAllergy,
                                  'doctor_notes': _notesController.text,
                                  'last_updated': "18 Mar 2026",
                                }
                              });

                              // Now update main screen state
                              setState(() {
                                ironDeficiency = tempIron;
                                bloodGroup = tempBlood;
                                medications =
                                    finalMeds.isEmpty ? "None" : finalMeds;
                                allergies = finalAllergy.isEmpty
                                    ? "None"
                                    : finalAllergy;
                                doctorNotes = _notesController.text;
                              });

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Profile Updated!"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating),
                                );
                              }
                            } catch (e) {
                              debugPrint(e.toString());
                            } finally {
                              setSheetState(() => _isSaving = false);
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Save Changes",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildDropdown(String label, List<String> options, String currentVal,
      Function(String?) onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(currentVal) ? currentVal : options[0],
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
        items: options
            .map((e) => DropdownMenuItem(
                value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
            .toList(),
        onChanged: onChange,
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 18),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget autoUpdateCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade600]),
          borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ])
      ]),
    );
  }

  Widget historyCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue.shade800, size: 18)),
        const SizedBox(width: 15),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color:
                      (value == "Not Set" || value == "None" || value == "No")
                          ? Colors.grey
                          : Colors.blueGrey,
                  fontSize: 13)),
        ])),
      ]),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 1.2));
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)),
      child: const Row(children: [
        Icon(Icons.tips_and_updates, color: Colors.blue, size: 18),
        SizedBox(width: 10),
        Expanded(
            child: Text(
                "HemoGlobe AI analyzes this profile to detect early signs of Anemia.",
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey,
                    fontStyle: FontStyle.italic))),
      ]),
    );
  }
}
