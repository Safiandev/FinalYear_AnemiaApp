import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FindClinicsScreen extends StatefulWidget {
  const FindClinicsScreen({super.key});

  @override
  State<FindClinicsScreen> createState() => _FindClinicsScreenState();
}

class _FindClinicsScreenState extends State<FindClinicsScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> clinics = [
    {
      "name": "Sialkot Medical Complex",
      "address": "Sialkot Cantt, Sialkot",
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
      "address": "Allama Iqbal Road, Sialkot",
      "phone": "+923998887776",
    },
    {
      "name": "Bethania Hospital",
      "address": "Sialkot City",
      "phone": "+92524264337",
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

  // --- PHONE CALL LOGIC ---
  Future<void> makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint("Could not launch phone dialer");
      }
    } catch (e) {
      debugPrint("Error launching dialer: $e");
    }
  }

  // --- GOOGLE MAPS LOGIC (FIXED) ---
  Future<void> openMap(String clinicName) async {
    // Google Maps Search Query Format
    final String query = Uri.encodeComponent(clinicName);
    final Uri url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch Maps");
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Find Clinics & Labs",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: searchController,
              onChanged: searchClinic,
              decoration: InputDecoration(
                hintText: "Search Sialkot clinics...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // --- CLINIC LIST ---
          Expanded(
            child: filteredClinics.isEmpty
                ? const Center(child: Text("No clinics found in Sialkot."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredClinics.length,
                    itemBuilder: (context, index) {
                      final clinic = filteredClinics[index];
                      return _clinicCard(clinic);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _clinicCard(Map<String, String> clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic["name"]!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      clinic["address"]!,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => makePhoneCall(clinic["phone"]!),
                  icon: const Icon(Icons.call, size: 18, color: Colors.white),
                  label: const Text("Call Now",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => openMap(clinic["name"]!),
                  icon: const Icon(Icons.directions_rounded,
                      size: 18, color: Colors.white),
                  label: const Text("Directions",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
