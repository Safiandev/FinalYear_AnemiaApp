import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FindClinicsScreen extends StatefulWidget {
  const FindClinicsScreen({super.key});

  @override
  State<FindClinicsScreen> createState() => _FindClinicsScreenState();
}

class _FindClinicsScreenState extends State<FindClinicsScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> clinics = [
    {
      "name": "Sialkot Medical Complex",
      "address": "Sialkot Cantt",
      "phone": "+923001234567",
    },
    {
      "name": "Chughtai Lab",
      "address": "Kashmir Road, Sialkot",
      "phone": "+923112223334",
    },
    {
      "name": "Al Shifa Lab",
      "address": "Paris Road, Sialkot",
      "phone": "+923334445556",
    },
    {
      "name": "Civil Hospital Sialkot",
      "address": "Allama Iqbal Road",
      "phone": "+923998887776",
    },
  ];

  List<Map<String, String>> filteredClinics = [];

  @override
  void initState() {
    super.initState();
    filteredClinics = clinics;
  }

  void searchClinic(String query) {
    final results = clinics.where((clinic) {
      final name = clinic["name"]!.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      filteredClinics = results;
    });
  }

  Future<void> makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> openMap(String clinicName) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$clinicName",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget clinicCard(Map<String, String> clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.local_hospital, color: Colors.blue),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  clinic["name"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(clinic["address"]!, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  makePhoneCall(clinic["phone"]!);
                },
                icon: const Icon(Icons.call),
                label: const Text("Call"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),

              const SizedBox(width: 10),

              ElevatedButton.icon(
                onPressed: () {
                  openMap(clinic["name"]!);
                },
                icon: const Icon(Icons.directions),
                label: const Text("Directions"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Clinics",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),

      backgroundColor: Colors.grey.shade100,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchClinic,
              decoration: InputDecoration(
                hintText: "Search clinics or labs",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: filteredClinics.length,
                itemBuilder: (context, index) {
                  return clinicCard(filteredClinics[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
