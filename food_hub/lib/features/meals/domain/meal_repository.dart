import 'meal.dart';

abstract class MealRepository {
  Future<List<MealCategory>> fetchCategories();
  Future<Meal> fetchRandomMeal();
  Future<Meal> fetchMealById(String id);
  Future<List<MealSummary>> searchByName(String query);
  Future<List<MealSummary>> searchByIngredient(String query);
  Future<List<MealSummary>> fetchByCategory(String category);
}
