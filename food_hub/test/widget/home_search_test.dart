import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_hub/core/l10n/app_localizations.dart';
import 'package:food_hub/features/home/presentation/home_screen.dart';
import 'package:food_hub/features/meals/domain/meal.dart';
import 'package:food_hub/features/meals/domain/meal_repository.dart';
import 'package:food_hub/features/meals/presentation/meal_providers.dart';

void main() {
  testWidgets('HomeScreen accepts search input and shows result', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealRepositoryProvider.overrideWithValue(_FakeMealRepository()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'pasta');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pasta'), findsWidgets);
  });
}

class _FakeMealRepository implements MealRepository {
  @override
  Future<List<MealCategory>> fetchCategories() async => [
        const MealCategory(id: '1', name: 'Seafood', thumbnailUrl: '', description: ''),
      ];

  @override
  Future<List<MealSummary>> fetchByCategory(String category) async => [
        const MealSummary(id: '2', name: 'Category Pasta', thumbnailUrl: ''),
      ];

  @override
  Future<Meal> fetchMealById(String id) async => const Meal(
        id: '2',
        name: 'Pasta',
        thumbnailUrl: '',
        category: 'Pasta',
        area: 'Italian',
        instructions: 'Cook.',
        youtubeUrl: '',
        ingredients: [],
      );

  @override
  Future<Meal> fetchRandomMeal() => fetchMealById('2');

  @override
  Future<List<MealSummary>> searchByIngredient(String query) async => searchByName(query);

  @override
  Future<List<MealSummary>> searchByName(String query) async => [
        const MealSummary(id: '2', name: 'Pasta', thumbnailUrl: ''),
      ];
}
