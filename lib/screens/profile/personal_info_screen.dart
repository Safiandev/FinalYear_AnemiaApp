import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/user_provider.dart'; // ✅ Ensure this path is correct

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightFeetController = TextEditingController();
  final TextEditingController heightInchesController = TextEditingController();

  String? selectedGender;
  String weightUnit = 'kg';
  String heightUnit = 'ft';
  bool _isSaving = false;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    // ✅ Load existing data from Provider into TextFields
    nameController.text = UserProvider.userName ?? "";
    ageController.text = UserProvider.userAge ?? "";

    // Check if current gender matches options
    if (genderOptions.contains(UserProvider.userGender)) {
      selectedGender = UserProvider.userGender;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightFeetController.dispose();
    heightInchesController.dispose();
    super.dispose();
  }

  // ---------- SAVE TO FIRESTORE LOGIC ----------
  Future<void> _saveData() async {
    String name = nameController.text.trim();
    String age = ageController.text.trim();

    if (name.isEmpty || age.isEmpty || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Update in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': name,
          'age': age,
          'gender': selectedGender,
          'weight': weightController.text.isNotEmpty
              ? "${weightController.text} $weightUnit"
              : "",
          'height': heightUnit == 'ft'
              ? "${heightFeetController.text}'${heightInchesController.text}\""
              : "${heightFeetController.text} cm",
        });

        // 2. Update ALL fields in local Provider (Syncing memory)
        UserProvider.updateAllData(
          name: name,
          age: age,
          gender: selectedGender,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Information Updated Successfully!")),
          );
          Navigator.pop(context); // Go back to Profile screen
        }
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            infoField("Name", nameController),
            infoField("Age", ageController, keyboardType: TextInputType.number),
            genderDropdown(),
            const SizedBox(height: 10),
            weightInput(),
            const SizedBox(height: 10),
            heightInput(),
            const SizedBox(height: 30),
            _isSaving
                ? const CircularProgressIndicator(color: Colors.blue)
                : saveButton(),
          ],
        ),
      ),
    );
  }

  // ---------- UI COMPONENTS ----------

  Widget infoField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget genderDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: const InputDecoration(
            border: InputBorder.none, labelText: "Gender"),
        items: genderOptions
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => selectedGender = v),
      ),
    );
  }

  Widget weightInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Weight (Optional)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: weightUnit,
          items: const [
            DropdownMenuItem(value: 'lbs', child: Text('lbs')),
            DropdownMenuItem(value: 'kg', child: Text('kg'))
          ],
          onChanged: (v) => setState(() => weightUnit = v!),
        ),
      ],
    );
  }

  Widget heightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text("Height (Optional)")),
        Row(
          children: [
            if (heightUnit == 'ft') ...[
              Expanded(child: heightField(heightFeetController, "ft")),
              const SizedBox(width: 8),
              Expanded(child: heightField(heightInchesController, "in")),
            ] else
              Expanded(child: heightField(heightFeetController, "cm")),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: heightUnit,
              items: const [
                DropdownMenuItem(value: 'ft', child: Text('ft/in')),
                DropdownMenuItem(value: 'cm', child: Text('cm'))
              ],
              onChanged: (v) => setState(() => heightUnit = v!),
            ),
          ],
        ),
      ],
    );
  }

  Widget heightField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Save Info",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white)),
      ),
    );
  }
}
