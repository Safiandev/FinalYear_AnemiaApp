import 'package:flutter/material.dart';

class DietSuggestionsScreen extends StatelessWidget {
  const DietSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Plan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share logic yahan add kar sakte ho
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nutritional Guidance box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.lightbulb, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'Pair iron-rich foods with '),
                            TextSpan(
                              text: 'Vitamin C',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' (like oranges or lemon) to enhance absorption. Avoid drinking tea or coffee during meals. ',
                            ),
                            TextSpan(
                              text: 'Learn more about absorption ›',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              // Add gesture recognizer here if you want
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Food categories filter bar (basic UI, no functional tabs here)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CategoryChip(label: 'All Foods', selected: true),
                  _CategoryChip(label: 'Vegetarian'),
                  _CategoryChip(label: 'Meats'),
                  _CategoryChip(label: 'Supplements'),
                ],
              ),

              const SizedBox(height: 20),

              // Recommended for You title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recommended for You',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'TOP SOURCES',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Food cards grid
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: const [
                  FoodCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1542831371-d531d36971e6?auto=format&fit=crop&w=600&q=80',
                    title: 'Spinach',
                    ironContent: '2.7mg Iron / 100g',
                    subtitle: 'LEAFY GREEN',
                    tag: 'BEST VEGGIE',
                  ),
                  FoodCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1590080877777-5cc931d73a91?auto=format&fit=crop&w=600&q=80',
                    title: 'Dates',
                    ironContent: '0.9mg Iron / 100g',
                    subtitle: 'FRUIT',
                  ),
                  FoodCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1589923188900-50a0b18b49f0?auto=format&fit=crop&w=600&q=80',
                    title: 'Beef Liver',
                    ironContent: '6.5mg Iron / 100g',
                    subtitle: 'ORGAN MEAT',
                    tag: 'HIGH IRON',
                  ),
                  FoodCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1608532380113-7f77e0277c4e?auto=format&fit=crop&w=600&q=80',
                    title: 'Lentils',
                    ironContent: '3.3mg Iron / 100g',
                    subtitle: 'LEGUME',
                  ),
                  FoodCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1553174777-8f23b20deec3?auto=format&fit=crop&w=600&q=80',
                    title: 'Red Meat',
                    ironContent: '2.6mg Iron / 100g',
                    subtitle: 'PROTEIN',
                  ),
                  FoodCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1542831371-d531d36971e6?auto=format&fit=crop&w=600&q=80',
                    title: 'Beans',
                    ironContent: '5.1mg Iron / 100g',
                    subtitle: 'LEGUME',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Personalized plan button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Need a Personalized Plan?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Consult our AI nutritionists for a meal plan tailored to your hematology results.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Add generate plan logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Generate Daily Plan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Category chip widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.green : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Food card widget
class FoodCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String ironContent;
  final String subtitle;
  final String? tag;

  const FoodCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.ironContent,
    required this.subtitle,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with optional tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (tag != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tag == 'HIGH IRON'
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ironContent,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
