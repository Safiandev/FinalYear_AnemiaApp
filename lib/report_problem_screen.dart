import 'package:flutter/material.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  String selectedIssue = "App Crash";
  TextEditingController problemController = TextEditingController();

  List<String> issueTypes = [
    "App Crash",
    "Wrong Detection Result",
    "Login Problem",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report a Problem",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade100,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Type
            const Text(
              "Select Issue Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                value: selectedIssue,
                isExpanded: true,
                underline: const SizedBox(),
                items: issueTypes.map((String issue) {
                  return DropdownMenuItem(value: issue, child: Text(issue));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIssue = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "Describe your problem",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: problemController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your problem here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 25),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // --------------------------
                  // Validation: message cannot be empty
                  // --------------------------
                  if (problemController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please write your problem before submitting",
                        ),
                      ),
                    );
                    return; // stop submission
                  }

                  // Success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Problem submitted successfully"),
                    ),
                  );

                  Navigator.pop(context); // close screen
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
