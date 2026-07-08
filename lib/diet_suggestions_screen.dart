import 'package:flutter/material.dart';

class DietSuggestionsScreen extends StatefulWidget {
  // --- NEW: Constructor updated to receive HB data ---
  final double? hbLevel;
  final String? userStatus; // "Low", "Normal", "High"

  const DietSuggestionsScreen({
    super.key,
    this.hbLevel,
    this.userStatus,
  });

  @override
  State<DietSuggestionsScreen> createState() => _DietSuggestionsScreenState();
}

class _DietSuggestionsScreenState extends State<DietSuggestionsScreen> {
  String selectedCategory = 'All Foods';

  // --- FULL DATASET (UNTOUCHED) ---
  final List<Map<String, dynamic>> allFoods = [
    {
      'title': 'Spinach (Palak)',
      'iron': '2.7mg / 100g',
      'subtitle': 'LEAFY GREEN',
      'tag': 'BEST VEGGIE',
      'category': 'Vegetarian',
      'image':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
      'detail':
          'Rich in Vitamin A & Iron. Cook with minimal water to keep nutrients.',
      'timing': 'Lunch or Dinner',
      'allergy': 'Avoid if you have kidney stones (Oxalates).',
    },
    {
      'title': 'Roasted Gram (Chana)',
      'iron': '5.3mg / 100g',
      'subtitle': 'POCKET SNACK',
      'tag': 'AFFORDABLE',
      'category': 'Vegetarian',
      'image':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      'detail': 'Very cheap and high in iron. Best daily snack for energy.',
      'timing': 'Evening Snack',
      'allergy': 'None. Safe for daily use.',
    },
    {
      'title': 'Beef Liver (Kaleji)',
      'iron': '6.5mg / 100g',
      'subtitle': 'ORGAN MEAT',
      'tag': 'MAX IRON',
      'category': 'Meats',
      'image':
          'https://images.unsplash.com/photo-1606851682837-018b0aaedab3?w=400',
      'detail': 'The most powerful source of heme-iron (animal-based).',
      'timing': 'Once a week (Lunch)',
      'allergy': 'High Vitamin A; avoid if pregnant without doctor advice.',
    },
    {
      'title': 'Pomegranate (Anar)',
      'iron': '0.3mg / 100g',
      'subtitle': 'FRUIT',
      'tag': 'BLOOD BOOST',
      'category': 'Vegetarian',
      'image':
          'https://images.unsplash.com/photo-1615485290382-441e4d0c9cb5?w=400',
      'detail': 'Excellent for refreshing blood and improving skin health.',
      'timing': 'Morning (Empty Stomach)',
      'allergy': 'Safe for everyone.',
    },
    {
      'title': 'Iron Supplement (Syrup)',
      'iron': 'Varies',
      'subtitle': 'MEDICINE',
      'tag': 'FAST ACTING',
      'category': 'Supplements',
      'image':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      'detail': 'Liquid iron for faster absorption in the body.',
      'timing': 'After Meals',
      'allergy': 'Can cause black stools or constipation.',
    },
    {
      'title': 'Folic Acid Tablet',
      'iron': '400mcg',
      'subtitle': 'VITAMIN',
      'tag': 'ESSENTIAL',
      'category': 'Supplements',
      'image':
          'https://images.unsplash.com/photo-1471864190281-ad5f9f33d70e?w=400',
      'detail': 'Helps in the production of red blood cells.',
      'timing': 'Once daily (Night)',
      'allergy': 'Consult doctor for dosage.',
    },
    {
      'title': 'Red Meat (Beef)',
      'iron': '2.6mg / 100g',
      'subtitle': 'PROTEIN',
      'tag': 'Heme-Iron',
      'category': 'Meats',
      'image':
          'https://images.unsplash.com/photo-1594041680534-e8c8cdebd679?w=400',
      'detail': 'Animal iron that body absorbs easily.',
      'timing': 'Lunch or Dinner',
      'allergy': 'High cholesterol risk if eaten daily.',
    },
    {
      'title': 'Kishmish (Raisins)',
      'iron': '1.9mg / 100g',
      'subtitle': 'DRIED FRUIT',
      'tag': 'CHEAP & LOCAL',
      'category': 'Vegetarian',
      'image':
          'https://images.unsplash.com/photo-1590080877777-5cc931d73a91?w=400',
      'detail': 'Soak overnight in water for better blood health.',
      'timing': 'Early Morning',
      'allergy': 'High sugar content.',
    },
    {
      'title': 'Boiled Eggs',
      'iron': '1.2mg / 2 Eggs',
      'subtitle': 'PROTEIN SOURCE',
      'tag': 'DAILY USE',
      'category': 'Meats',
      'image':
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400',
      'detail': 'Affordable protein and easy to digest iron source.',
      'timing': 'Breakfast',
      'allergy': 'Avoid if you have an egg allergy.',
    },
    {
      'title': 'Lentils (Daal)',
      'iron': '3.3mg / 100g',
      'subtitle': 'PULSES',
      'tag': 'AFFORDABLE',
      'category': 'Vegetarian',
      'image':
          'https://images.unsplash.com/photo-1515942400420-2b98fed1f515?w=400',
      'detail': 'Excellent plant-based iron. Use lemon on top for absorption.',
      'timing': 'Lunch',
      'allergy': 'Can cause bloating.',
    },
    {
      'title': 'Dates (Khajoor)',
      'iron': '1.0mg / 100g',
      'subtitle': 'FRUIT',
      'tag': 'ENERGY BOOST',
      'category': 'Vegetarian',
      'image':
          'https://images.unsplash.com/photo-1541481910298-638dad9efac3?w=400',
      'detail': 'Packed with energy and iron. Great for hemoglobin.',
      'timing': 'Anytime snack',
      'allergy': 'Safe, but high in sugar.',
    },
    {
      'title': 'Chicken Breast',
      'iron': '1.0mg / 100g',
      'subtitle': 'LEAN MEAT',
      'tag': 'PROTEIN',
      'category': 'Meats',
      'image':
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400',
      'detail': 'Easier on the stomach than beef but still provides iron.',
      'timing': 'Dinner',
      'allergy': 'None.',
    },
  ];

// --- NEW & SMARTER: LOGIC TO GET RECOMMENDED ITEMS ---
  List<Map<String, dynamic>> get recommendedItems {
    if (widget.userStatus == 'Low') {
      // 1. Agar Hemoglobin boht kam hai (e.g. Below 9.0) -> Show Supplements + Max Iron
      if (widget.hbLevel != null && widget.hbLevel! < 9.0) {
        return allFoods
            .where((f) =>
                f['category'] == 'Supplements' ||
                f['tag'] == 'MAX IRON' ||
                f['tag'] == 'FAST ACTING')
            .toList();
      }
      // 2. Agar level thora sa kam hai (Mild like 11.5) -> Show Natural Iron Foods
      else {
        return allFoods
            .where((f) =>
                f['tag'] == 'BEST VEGGIE' ||
                f['tag'] == 'BLOOD BOOST' ||
                f['category'] == 'Vegetarian')
            .take(5)
            .toList();
      }
    } else if (widget.userStatus == 'High') {
      return allFoods
          .where((f) => f['category'] == 'Vegetarian' && f['tag'] != 'MAX IRON')
          .toList();
    } else if (widget.userStatus == 'Normal') {
      return allFoods
          .where((f) => f['tag'] == 'DAILY USE' || f['tag'] == 'BLODA BOOST')
          .take(4)
          .toList();
    }

    return [];
  }

  List<Map<String, dynamic>> get filteredFoods {
    if (selectedCategory == 'All Foods') return allFoods;
    return allFoods.where((f) => f['category'] == selectedCategory).toList();
  }

  void _showFoodDetail(Map<String, dynamic> food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    food['image'] ?? '',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food['title'] ?? 'Food Item',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(food['iron'] ?? 'N/A',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            _infoTile(Icons.info_outline, "Details",
                food['detail'] ?? "Good for health."),
            _infoTile(Icons.access_time, "Best Time to Eat",
                food['timing'] ?? "Anytime"),
            _infoTile(Icons.warning_amber_rounded, "Allergy/Precaution",
                food['allergy'] ?? "No specific notes.",
                color: Colors.orange.shade700),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Got it!",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showProTipPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.amber.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 40),
            ),
            const SizedBox(height: 20),
            const Text("Vitamin C is the Key!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "Sirf Iron khana kafi nahi hota. Lemon, Orange juice, ya Tamatar (Vitamin C) ka istemal iron ki absorption ko 3 guna tak barha deta hai.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Got it!",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value,
      {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: const Text('Dietary Plan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW: RECOMMENDED SECTION (Only shows if status is passed) ---
            if (widget.userStatus != null) ...[
              Text(
                widget.userStatus == 'Low'
                    ? "Recommended for Low Hemoglobin"
                    : "Tailored for Your Result",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 175,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedItems.length,
                  itemBuilder: (context, index) {
                    final item = recommendedItems[index];
                    return GestureDetector(
                      onTap: () => _showFoodDetail(item),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 15, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                    child: Image.network(item['image'],
                                        width: double.infinity,
                                        fit: BoxFit.cover))),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                        maxLines: 1),
                                    Text(item['iron'],
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10)),
                                  ]),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
            ],

            // --- PRO TIP BOX (AS PROVIDED) ---
            GestureDetector(
              onTap: _showProTipPopup,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Iron Absorption Tip",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          Text("Tap to learn how to boost results",
                              style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.green, size: 26),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- TABS (UNTOUCHED) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All Foods', 'Vegetarian', 'Meats', 'Supplements']
                    .map((cat) {
                  bool isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => selectedCategory = cat),
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 13),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 25),

            // --- GRID VIEW (UNTOUCHED) ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFoods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.72),
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return GestureDetector(
                  onTap: () => _showFoodDetail(food),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Image.network(
                                  food['image'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey.shade100,
                                      child: const Icon(Icons.fastfood)),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(food['tag'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food['title'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                  maxLines: 1),
                              Text(food['iron'],
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(food['subtitle'],
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 9)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
