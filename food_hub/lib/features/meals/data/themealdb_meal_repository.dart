import '../domain/meal.dart';
import '../domain/meal_repository.dart';
import 'themealdb_data_source.dart';
import '../../../core/errors/app_error.dart';

class TheMealDbMealRepository implements MealRepository {
  const TheMealDbMealRepository(this._dataSource);

  final TheMealDbDataSource _dataSource;

  @override
  Future<List<MealCategory>> fetchCategories() async {
    final json = await _dataSource.get('categories.php', {});
    final list = (json['categories'] as List? ?? const []);
    return list.map((item) => MealCategory.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<MealSummary>> fetchByCategory(String category) async {
    final json = await _dataSource.get('filter.php', {'c': category});
    return _summaries(json);
  }

  @override
  Future<Meal> fetchMealById(String id) async {
    final json = await _dataSource.get('lookup.php', {'i': id});
    final list = (json['meals'] as List? ?? const []);
    if (list.isEmpty) throw const MealApiException(AppErrorType.mealNotFound);
    return Meal.fromJson(list.first as Map<String, dynamic>);
  }

  @override
  Future<Meal> fetchRandomMeal() async {
    final json = await _dataSource.get('random.php', {});
    final list = (json['meals'] as List? ?? const []);
    if (list.isEmpty) throw const MealApiException(AppErrorType.randomMealNotFound);
    return Meal.fromJson(list.first as Map<String, dynamic>);
  }

  @override
  Future<List<MealSummary>> searchByIngredient(String query) async {
    final json = await _dataSource.get('filter.php', {'i': query});
    return _summaries(json);
  }

  @override
  Future<List<MealSummary>> searchByName(String query) async {
    final json = await _dataSource.get('search.php', {'s': query});
    return _summaries(json);
  }

  List<MealSummary> _summaries(Map<String, dynamic> json) {
    final list = (json['meals'] as List? ?? const []);
    return list.map((item) => MealSummary.fromJson(item as Map<String, dynamic>)).toList();
  }
}
