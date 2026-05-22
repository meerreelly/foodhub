import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_hub/features/meals/domain/meal.dart';
import 'package:food_hub/features/shared/presentation/recipe_card.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('RecipeCard renders recipe title', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const RecipeCard(meal: MealSummary(id: '1', name: 'Pasta', thumbnailUrl: ''))),
        GoRoute(path: '/recipe/:id', builder: (context, state) => const Scaffold(body: Text('Details'))),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Pasta'), findsOneWidget);
  });
}
