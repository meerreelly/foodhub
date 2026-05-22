class IngredientMeasure {
  const IngredientMeasure({
    required this.ingredient,
    required this.measure,
  });

  final String ingredient;
  final String measure;
}

class MealSummary {
  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
  });

  final String id;
  final String name;
  final String thumbnailUrl;

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Unknown meal',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': id,
        'strMeal': name,
        'strMealThumb': thumbnailUrl,
      };
}

class Meal extends MealSummary {
  const Meal({
    required super.id,
    required super.name,
    required super.thumbnailUrl,
    required this.category,
    required this.area,
    required this.instructions,
    required this.youtubeUrl,
    required this.ingredients,
  });

  final String category;
  final String area;
  final String instructions;
  final String youtubeUrl;
  final List<IngredientMeasure> ingredients;

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <IngredientMeasure>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim() ?? '';
      final measure = json['strMeasure$i']?.toString().trim() ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add(IngredientMeasure(ingredient: ingredient, measure: measure));
      }
    }

    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Unknown meal',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      youtubeUrl: json['strYoutube']?.toString() ?? '',
      ingredients: ingredients,
    );
  }
}

class MealCategory {
  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  final String id;
  final String name;
  final String thumbnailUrl;
  final String description;

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory']?.toString() ?? '',
      name: json['strCategory']?.toString() ?? '',
      thumbnailUrl: json['strCategoryThumb']?.toString() ?? '',
      description: json['strCategoryDescription']?.toString() ?? '',
    );
  }
}
