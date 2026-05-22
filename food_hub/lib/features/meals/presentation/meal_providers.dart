import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/themealdb_data_source.dart';
import '../data/themealdb_meal_repository.dart';
import '../domain/meal.dart';
import '../domain/meal_repository.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return TheMealDbMealRepository(TheMealDbDataSource());
});

final categoriesProvider = FutureProvider<List<MealCategory>>((ref) {
  return ref.watch(mealRepositoryProvider).fetchCategories();
});

final randomMealProvider = FutureProvider<Meal>((ref) {
  return ref.watch(mealRepositoryProvider).fetchRandomMeal();
});

final mealDetailsProvider = FutureProvider.family<Meal, String>((ref, id) {
  return ref.watch(mealRepositoryProvider).fetchMealById(id);
});

final categoryMealsProvider = FutureProvider.family<List<MealSummary>, String>((ref, category) {
  return ref.watch(mealRepositoryProvider).fetchByCategory(category);
});

enum SearchMode { name, ingredient }

class SearchQuery {
  const SearchQuery({required this.query, required this.mode});

  final String query;
  final SearchMode mode;
}

final searchMealsProvider = FutureProvider.family<List<MealSummary>, SearchQuery>((ref, search) {
  if (search.query.trim().isEmpty) return Future.value(const []);
  final repo = ref.watch(mealRepositoryProvider);
  return search.mode == SearchMode.name
      ? repo.searchByName(search.query.trim())
      : repo.searchByIngredient(search.query.trim());
});
