import 'package:flutter/material.dart';
import 'package:promedia_v2/food_item.dart';
import 'tkpi_data.dart';

// Widget untuk menampilkan daftar makanan dengan kategori
class FoodListWithCategory extends StatefulWidget {
  final Function(FoodItem) onFoodSelected;

  const FoodListWithCategory({
    super.key,
    required this.onFoodSelected,
  });

  @override
  State<FoodListWithCategory> createState() => _FoodListWithCategoryState();
}

class _FoodListWithCategoryState extends State<FoodListWithCategory> {
  String? selectedCategory;
  String searchQuery = '';

  List<FoodItem> getFilteredFoods() {
    List<FoodItem> foods = TKPIData.foods;

    // Filter by category
    if (selectedCategory != null) {
      foods = foods.where((food) => food.category == selectedCategory).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      foods = foods.where((food) {
        return food.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return foods;
  }

  @override
  Widget build(BuildContext context) {
    final categories = TKPIData.getCategories();
    final filteredFoods = getFilteredFoods();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari makanan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),

        // Category Chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Semua'),
                    selected: selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = null;
                      });
                    },
                    selectedColor: const Color(0xFFB83B7E),
                    labelStyle: TextStyle(
                      color: selectedCategory == null ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }

              final category = categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: const Color(0xFFB83B7E),
                  labelStyle: TextStyle(
                    color: selectedCategory == category ? Colors.white : Colors.black87,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Food Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filteredFoods.length} makanan ditemukan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Food List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredFoods.length,
            itemBuilder: (context, index) {
              final food = filteredFoods[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => widget.onFoodSelected(food),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Icon berdasarkan kategori
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(food.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(food.category),
                            color: _getCategoryColor(food.category),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Info Makanan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                food.category,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildNutrientChip(
                                    '${food.energyKcal.toStringAsFixed(0)} kkal',
                                    Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildNutrientChip(
                                    '${food.carbohydrate.toStringAsFixed(1)}g karbo',
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Serealia':
        return Icons.rice_bowl;
      case 'Umbi':
        return Icons.spa;
      case 'Protein Hewani':
        return Icons.set_meal;
      case 'Protein Nabati':
        return Icons.food_bank;
      case 'Sayuran':
        return Icons.local_florist;
      case 'Buah':
        return Icons.apple;
      case 'Minuman':
        return Icons.local_drink;
      case 'Makanan Olahan':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Serealia':
        return Colors.brown;
      case 'Umbi':
        return Colors.orange;
      case 'Protein Hewani':
        return Colors.red;
      case 'Protein Nabati':
        return Colors.green;
      case 'Sayuran':
        return Colors.lightGreen;
      case 'Buah':
        return Colors.purple;
      case 'Minuman':
        return Colors.blue;
      case 'Makanan Olahan':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

// Widget untuk menampilkan detail nutrisi makanan
class FoodNutritionDetail extends StatelessWidget {
  final FoodItem food;
  final double grams;

  const FoodNutritionDetail({
    super.key,
    required this.food,
    required this.grams,
  });

  @override
  Widget build(BuildContext context) {
    final calories = food.calculateCalories(grams);
    final carbs = food.calculateCarbs(grams);
    final protein = food.calculateProtein(grams);
    final fat = food.calculateFat(grams);
    final fiber = food.calculateFiber(grams);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                food.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB83B7E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${grams.toStringAsFixed(0)}g',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildNutrientRow('Kalori', calories.toStringAsFixed(0), 'kkal', Colors.orange),
          const SizedBox(height: 12),
          _buildNutrientRow('Karbohidrat', carbs.toStringAsFixed(1), 'g', Colors.blue),
          const SizedBox(height: 12),
          _buildNutrientRow('Protein', protein.toStringAsFixed(1), 'g', Colors.red),
          const SizedBox(height: 12),
          _buildNutrientRow('Lemak', fat.toStringAsFixed(1), 'g', Colors.yellow.shade700),
          const SizedBox(height: 12),
          _buildNutrientRow('Serat', fiber.toStringAsFixed(1), 'g', Colors.green),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, String unit, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          '$value $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}