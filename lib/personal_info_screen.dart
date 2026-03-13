import 'package:flutter/material.dart';

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
  String weightUnit = 'lbs'; // 'lbs' or 'kg'
  String heightUnit = 'ft'; // 'ft' or 'cm'

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightFeetController.dispose();
    heightInchesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Personal Information",
          style: TextStyle(color: Colors.black),
        ),
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
            saveButton(),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets ----------

  Widget infoField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget genderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Gender",
        ),
        items: genderOptions.map((gender) {
          return DropdownMenuItem<String>(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value;
          });
        },
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
              labelText: "Weight",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: weightUnit,
          items: const [
            DropdownMenuItem(value: 'lbs', child: Text('lbs')),
            DropdownMenuItem(value: 'kg', child: Text('kg')),
          ],
          onChanged: (value) {
            setState(() {
              weightUnit = value!;
            });
          },
        ),
      ],
    );
  }

  Widget heightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Height"),
        const SizedBox(height: 5),
        Row(
          children: [
            if (heightUnit == 'ft') ...[
              Expanded(
                child: TextField(
                  controller: heightFeetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Feet",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: heightInchesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Inches",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: TextField(
                  controller: heightFeetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "cm",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: heightUnit,
              items: const [
                DropdownMenuItem(value: 'ft', child: Text('ft/in')),
                DropdownMenuItem(value: 'cm', child: Text('cm')),
              ],
              onChanged: (value) {
                setState(() {
                  heightUnit = value!;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          String name = nameController.text.trim();
          String age = ageController.text.trim();
          String? gender = selectedGender;
          String? weight = weightController.text.trim().isEmpty
              ? null
              : weightController.text.trim();
          String? height;

          if (heightUnit == 'ft') {
            String feet = heightFeetController.text.trim();
            String inches = heightInchesController.text.trim();
            height = (feet.isEmpty && inches.isEmpty)
                ? null
                : "$feet ft $inches in";
          } else {
            height = heightFeetController.text.trim().isEmpty
                ? null
                : "${heightFeetController.text.trim()} cm";
          }

          if (name.isEmpty || age.isEmpty || gender == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please fill all required fields")),
            );
            return;
          }

          print(
            "Name: $name, Age: $age, Gender: $gender, Weight: $weight $weightUnit, Height: $height",
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Personal info saved successfully!")),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          "Save Info",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
