import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/user_provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController =
      TextEditingController(); // Optional
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

    _loadExistingFirestoreData();
  }

  // Fetch phone number if saved previously
  Future<void> _loadExistingFirestoreData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
          if (mounted && data['phone'] != null) {
            setState(() {
              phoneController.text = data['phone'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching phone detail: $e");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Please fill all required fields"),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Update in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'age': age,
          'gender': selectedGender,
          'phone': phoneController.text.trim(),
          'weight': weightController.text.isNotEmpty
              ? "${weightController.text} $weightUnit"
              : "",
          'height': heightUnit == 'ft'
              ? "${heightFeetController.text}'${heightInchesController.text}\""
              : "${heightFeetController.text} cm",
        }, SetOptions(merge: true));

        // 2. Update ALL fields in local Provider (Syncing memory)
        UserProvider.updateAllData(
          name: name,
          age: age,
          gender: selectedGender,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text("Information Updated Successfully!"),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context); // Go back to Profile screen
        }
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Personal Information",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              title: "Basic Details",
              subtitle: "Enter your primary identity & contact info",
              icon: Icons.person_pin_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardBoxDecoration(),
              child: Column(
                children: [
                  infoField(
                    "Full Name *",
                    nameController,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  infoField(
                    "Age *",
                    ageController,
                    Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  genderDropdown(),
                  const SizedBox(height: 16),
                  infoField(
                    "Phone Number (Optional)",
                    phoneController,
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _sectionHeader(
              title: "Physical Vitals",
              subtitle: "Optional details for better health insights",
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardBoxDecoration(),
              child: Column(
                children: [
                  weightInput(),
                  const SizedBox(height: 16),
                  heightInput(),
                ],
              ),
            ),
            const SizedBox(height: 36),
            _isSaving
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                : saveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------- REUSABLE UI COMPONENTS ----------

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3F51B5).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3F51B5),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.03),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget infoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
        ),
      ),
    );
  }

  Widget genderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedGender,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      icon:
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: "Gender *",
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixIcon:
            const Icon(Icons.wc_outlined, color: Color(0xFF3F51B5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
        ),
      ),
      items: genderOptions
          .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedGender = v),
    );
  }

  Widget weightInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: "Weight",
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              prefixIcon: const Icon(
                Icons.monitor_weight_outlined,
                color: Color(0xFF3F51B5),
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: weightUnit,
              style: const TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF3F51B5)),
              items: const [
                DropdownMenuItem(value: 'kg', child: Text('kg')),
                DropdownMenuItem(value: 'lbs', child: Text('lbs')),
              ],
              onChanged: (v) => setState(() => weightUnit = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget heightInput() {
    return Row(
      children: [
        if (heightUnit == 'ft') ...[
          Expanded(
            child: heightField(
              heightFeetController,
              "Ft",
              Icons.height_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: heightField(
              heightInchesController,
              "Inches",
              Icons.height_rounded,
            ),
          ),
        ] else
          Expanded(
            child: heightField(
              heightFeetController,
              "Cm",
              Icons.height_rounded,
            ),
          ),
        const SizedBox(width: 10),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: heightUnit,
              style: const TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF3F51B5)),
              items: const [
                DropdownMenuItem(value: 'ft', child: Text('ft/in')),
                DropdownMenuItem(value: 'cm', child: Text('cm')),
              ],
              onChanged: (v) => setState(() => heightUnit = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget heightField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: "Height ($label)",
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F51B5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Save Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hemoglobe_ai/user_provider.dart';

// class PersonalInfoScreen extends StatefulWidget {
//   const PersonalInfoScreen({super.key});

//   @override
//   State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
// }

// class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController(); // Optional
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController heightFeetController = TextEditingController();
//   final TextEditingController heightInchesController = TextEditingController();

//   String? selectedGender;
//   String weightUnit = 'kg';
//   String heightUnit = 'ft';
//   bool _isSaving = false;

//   final List<String> genderOptions = ['Male', 'Female', 'Other'];

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Load existing data from Provider into TextFields
//     nameController.text = UserProvider.userName ?? "";
//     ageController.text = UserProvider.userAge ?? "";

//     // Check if current gender matches options
//     if (genderOptions.contains(UserProvider.userGender)) {
//       selectedGender = UserProvider.userGender;
//     }

//     _loadExistingFirestoreData();
//   }

//   // Fetch phone number if saved previously
//   Future<void> _loadExistingFirestoreData() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (doc.exists && doc.data() != null) {
//           var data = doc.data() as Map<String, dynamic>;
//           if (mounted && data['phone'] != null) {
//             setState(() {
//               phoneController.text = data['phone'];
//             });
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Error fetching phone detail: $e");
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     ageController.dispose();
//     phoneController.dispose();
//     weightController.dispose();
//     heightFeetController.dispose();
//     heightInchesController.dispose();
//     super.dispose();
//   }

//   // ---------- SAVE TO FIRESTORE LOGIC ----------
//   Future<void> _saveData() async {
//     String name = nameController.text.trim();
//     String age = ageController.text.trim();

//     if (name.isEmpty || age.isEmpty || selectedGender == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Please fill all required fields"),
//           backgroundColor: Colors.red.shade600,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // 1. Update in Firestore
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .set({
//           'name': name,
//           'age': age,
//           'gender': selectedGender,
//           'phone': phoneController.text.trim(),
//           'weight': weightController.text.isNotEmpty
//               ? "${weightController.text} $weightUnit"
//               : "",
//           'height': heightUnit == 'ft'
//               ? "${heightFeetController.text}'${heightInchesController.text}\""
//               : "${heightFeetController.text} cm",
//         }, SetOptions(merge: true));

//         // 2. Update ALL fields in local Provider (Syncing memory)
//         UserProvider.updateAllData(
//           name: name,
//           age: age,
//           gender: selectedGender,
//         );

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Information Updated Successfully!"),
//               backgroundColor: Colors.green,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//           Navigator.pop(context); // Go back to Profile screen
//         }
//       }
//     } catch (e) {
//       debugPrint("Update Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: ${e.toString()}"),
//             backgroundColor: Colors.red.shade600,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text(
//           "Personal Information",
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black87),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _sectionTitle("Basic Details"),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: _cardBoxDecoration(),
//               child: Column(
//                 children: [
//                   infoField("Full Name *", nameController, Icons.person_outline_rounded),
//                   const SizedBox(height: 12),
//                   infoField("Age *", ageController, Icons.cake_outlined,
//                       keyboardType: TextInputType.number),
//                   const SizedBox(height: 12),
//                   genderDropdown(),
//                   const SizedBox(height: 12),
//                   infoField("Phone Number (Optional)", phoneController,
//                       Icons.phone_outlined,
//                       keyboardType: TextInputType.phone),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 22),

//             _sectionTitle("Physical Vitals (Optional)"),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: _cardBoxDecoration(),
//               child: Column(
//                 children: [
//                   weightInput(),
//                   const SizedBox(height: 12),
//                   heightInput(),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),

//             _isSaving
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.indigo))
//                 : saveButton(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------- REUSABLE UI COMPONENTS ----------

//   BoxDecoration _cardBoxDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: Colors.grey.shade200),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.02),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           color: Colors.indigo.shade800,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }

//   Widget infoField(
//       String label, TextEditingController controller, IconData icon,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: const TextStyle(fontSize: 14, color: Colors.black87),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//         prefixIcon: Icon(icon, color: Colors.indigo.shade400, size: 20),
//         filled: true,
//         fillColor: const Color(0xFFF8F9FA),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
//         ),
//       ),
//     );
//   }

//   Widget genderDropdown() {
//     return DropdownButtonFormField<String>(
//       value: selectedGender,
//       style: const TextStyle(fontSize: 14, color: Colors.black87),
//       decoration: InputDecoration(
//         labelText: "Gender *",
//         labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//         prefixIcon:
//             Icon(Icons.wc_outlined, color: Colors.indigo.shade400, size: 20),
//         filled: true,
//         fillColor: const Color(0xFFF8F9FA),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
//         ),
//       ),
//       items: genderOptions
//           .map((g) => DropdownMenuItem(value: g, child: Text(g)))
//           .toList(),
//       onChanged: (v) => setState(() => selectedGender = v),
//     );
//   }

//   Widget weightInput() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: weightController,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(fontSize: 14, color: Colors.black87),
//             decoration: InputDecoration(
//               labelText: "Weight",
//               labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//               prefixIcon: Icon(Icons.monitor_weight_outlined,
//                   color: Colors.indigo.shade400, size: 20),
//               filled: true,
//               fillColor: const Color(0xFFF8F9FA),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade200),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8F9FA),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: weightUnit,
//               style: TextStyle(
//                   color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
//               items: const [
//                 DropdownMenuItem(value: 'kg', child: Text('kg')),
//                 DropdownMenuItem(value: 'lbs', child: Text('lbs')),
//               ],
//               onChanged: (v) => setState(() => weightUnit = v!),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget heightInput() {
//     return Row(
//       children: [
//         if (heightUnit == 'ft') ...[
//           Expanded(
//               child: heightField(
//                   heightFeetController, "Ft", Icons.height_rounded)),
//           const SizedBox(width: 8),
//           Expanded(
//               child: heightField(
//                   heightInchesController, "Inches", Icons.height_rounded)),
//         ] else
//           Expanded(
//               child: heightField(
//                   heightFeetController, "Cm", Icons.height_rounded)),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8F9FA),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: heightUnit,
//               style: TextStyle(
//                   color: Colors.indigo.shade700,
//                   fontWeight: FontWeight.bold),
//               items: const [
//                 DropdownMenuItem(value: 'ft', child: Text('ft/in')),
//                 DropdownMenuItem(value: 'cm', child: Text('cm')),
//               ],
//               onChanged: (v) => setState(() => heightUnit = v!),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget heightField(
//       TextEditingController controller, String label, IconData icon) {
//     return TextField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       style: const TextStyle(fontSize: 14, color: Colors.black87),
//       decoration: InputDecoration(
//         labelText: "Height ($label)",
//         labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//         prefixIcon: Icon(icon, color: Colors.indigo.shade400, size: 20),
//         filled: true,
//         fillColor: const Color(0xFFF8F9FA),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
//         ),
//       ),
//     );
//   }

//   Widget saveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         onPressed: _saveData,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.indigo,
//           elevation: 2,
//           shadowColor: Colors.indigo.withOpacity(0.3),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: const Text(
//           "Save Information",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Colors.white,
//             letterSpacing: 0.2,
//           ),
//         ),
//       ),
//     );
//   }
// }

