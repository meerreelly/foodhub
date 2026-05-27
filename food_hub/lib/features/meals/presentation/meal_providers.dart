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
  const SearchQuery({required this.query, required this.mode, this.category});

  final String query;
  final SearchMode mode;
  final String? category;

  @override
  bool operator ==(Object other) {
    return other is SearchQuery &&
        other.query == query &&
        other.mode == mode &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(query, mode, category);
}

final searchMealsProvider = FutureProvider.family<List<MealSummary>, SearchQuery>((ref, search) {
  if (search.query.trim().isEmpty && (search.category?.isEmpty ?? true)) {
    return Future.value(const []);
  }
  final repo = ref.watch(mealRepositoryProvider);
  if (search.query.trim().isEmpty && search.category != null) {
    return repo.fetchByCategory(search.category!);
  }
  return search.mode == SearchMode.name
      ? repo.searchByName(search.query.trim())
      : repo.searchByIngredient(search.query.trim());
});
