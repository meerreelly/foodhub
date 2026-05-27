import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/glass.dart';
import '../data/custom_recipe_repository.dart';

class MyRecipesScreen extends ConsumerWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(myRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('myRecipes')),
        actions: [
          IconButton.filledTonal(
            onPressed: () => context.push(AppRoutes.addRecipe),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: recipes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(localizedError(context, error))),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.t('emptyMyRecipes')));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return GlassPanel(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add_circle_rounded),
                    title: Text(l10n.t('addRecipe')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.addRecipe),
                  ),
                );
              }
              final recipe = items[index - 1];
              return GlassPanel(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: _RecipeThumb(recipe: recipe),
                  title: Text(recipe.title),
                  subtitle: Text(recipe.category),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.customRecipe(recipe.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecipeThumb extends StatelessWidget {
  const _RecipeThumb({required this.recipe});

  final CustomRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe.imageUrl;
    final localImagePath = recipe.localImagePath;
    return SizedBox.square(
      dimension: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: switch ((imageUrl, localImagePath)) {
          (final remote, _) when remote.isNotEmpty => CachedNetworkImage(
            imageUrl: remote,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(Icons.restaurant),
          ),
          (_, final local) when local.isNotEmpty => Image.file(
            File(local),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.restaurant),
          ),
          _ => const ColoredBox(
            color: Colors.black12,
            child: Icon(Icons.restaurant),
          ),
        },
      ),
    );
  }
}
