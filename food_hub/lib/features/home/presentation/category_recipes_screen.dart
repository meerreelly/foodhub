import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../meals/presentation/meal_providers.dart';
import '../../shared/presentation/async_value_view.dart';
import '../../shared/presentation/recipe_card.dart';

class CategoryRecipesScreen extends ConsumerWidget {
  const CategoryRecipesScreen({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decoded = Uri.decodeComponent(category);
    final meals = ref.watch(categoryMealsProvider(decoded));
    return Scaffold(
      appBar: AppBar(title: Text(decoded)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(categoryMealsProvider(decoded)),
        child: AsyncValueView(
          value: meals,
          retry: () => ref.invalidate(categoryMealsProvider(decoded)),
          data: (items) => GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .78, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, index) => RecipeCard(meal: items[index]),
          ),
        ),
      ),
    );
  }
}
