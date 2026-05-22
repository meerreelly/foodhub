import 'package:flutter_test/flutter_test.dart';
import 'package:food_hub/features/meals/domain/meal.dart';

void main() {
  test('Meal.fromJson parses main fields', () {
    final meal = Meal.fromJson({
      'idMeal': '1',
      'strMeal': 'Borscht',
      'strMealThumb': '',
      'strCategory': 'Soup',
      'strArea': 'Ukrainian',
      'strInstructions': 'Cook it.',
      'strYoutube': '',
    });

    expect(meal.id, '1');
    expect(meal.name, 'Borscht');
    expect(meal.category, 'Soup');
    expect(meal.area, 'Ukrainian');
  });

  test('Meal.fromJson parses ingredient and measure pairs', () {
    final meal = Meal.fromJson({
      'idMeal': '1',
      'strMeal': 'Borscht',
      'strIngredient1': 'Beetroot',
      'strMeasure1': '2',
      'strIngredient2': 'Cabbage',
      'strMeasure2': '100g',
      'strIngredient3': '',
      'strMeasure3': '',
    });

    expect(meal.ingredients, hasLength(2));
    expect(meal.ingredients.first.ingredient, 'Beetroot');
    expect(meal.ingredients.last.measure, '100g');
  });

  test('MealSummary.fromJson tolerates missing optional thumbnail', () {
    final summary = MealSummary.fromJson({'idMeal': '7', 'strMeal': 'Rice'});

    expect(summary.id, '7');
    expect(summary.name, 'Rice');
    expect(summary.thumbnailUrl, '');
  });

  test('MealCategory.fromJson parses category data', () {
    final category = MealCategory.fromJson({
      'idCategory': '2',
      'strCategory': 'Dessert',
      'strCategoryThumb': '',
      'strCategoryDescription': 'Sweet food',
    });

    expect(category.id, '2');
    expect(category.name, 'Dessert');
    expect(category.description, 'Sweet food');
  });

  test('Meal.fromJson ignores blank ingredients', () {
    final meal = Meal.fromJson({
      'idMeal': '1',
      'strMeal': 'Salad',
      'strIngredient1': ' ',
      'strMeasure1': '1',
      'strIngredient2': 'Tomato',
      'strMeasure2': '2',
    });

    expect(meal.ingredients, hasLength(1));
    expect(meal.ingredients.single.ingredient, 'Tomato');
  });
}
