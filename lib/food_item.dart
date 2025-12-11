class FoodItem {
  final String name;
  final String category;
  final double energyKcal; // kalori per 100g
  final double protein; // gram per 100g
  final double fat; // gram per 100g
  final double carbohydrate; // gram per 100g
  final double fiber; // gram per 100g

  FoodItem({
    required this.name,
    required this.category,
    required this.energyKcal,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.fiber,
  });

  // Hitung kalori berdasarkan porsi dalam gram
  double calculateCalories(double gramsWeight) {
    return (energyKcal / 100) * gramsWeight;
  }

  // Hitung karbohidrat berdasarkan porsi dalam gram
  double calculateCarbs(double gramsWeight) {
    return (carbohydrate / 100) * gramsWeight;
  }

  // Hitung protein berdasarkan porsi dalam gram
  double calculateProtein(double gramsWeight) {
    return (protein / 100) * gramsWeight;
  }

  // Hitung lemak berdasarkan porsi dalam gram
  double calculateFat(double gramsWeight) {
    return (fat / 100) * gramsWeight;
  }

  // Hitung serat berdasarkan porsi dalam gram
  double calculateFiber(double gramsWeight) {
    return (fiber / 100) * gramsWeight;
  }
}