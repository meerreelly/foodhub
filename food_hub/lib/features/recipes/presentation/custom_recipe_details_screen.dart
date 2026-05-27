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

class CustomRecipeDetailsScreen extends ConsumerWidget {
  const CustomRecipeDetailsScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(myRecipesProvider);
    return recipes.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text(localizedError(context, error)))),
      data: (items) {
        final recipe = _findRecipe(items, id);
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(AppLocalizations.of(context).t('recipeNotFound')),
            ),
          );
        }
        return _DetailsBody(recipe: recipe);
      },
    );
  }

  CustomRecipe? _findRecipe(List<CustomRecipe> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({required this.recipe});

  final CustomRecipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(recipe.title),
            actions: [
              IconButton.filledTonal(
                onPressed: () =>
                    context.push(AppRoutes.editCustomRecipe(recipe.id)),
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton.filledTonal(
                onPressed: () => _delete(context, ref),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _RecipeImage(recipe: recipe),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverList.list(
              children: [
                if (recipe.category.isNotEmpty)
                  Chip(label: Text(recipe.category)),
                const SizedBox(height: 18),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        icon: Icons.checklist_rounded,
                        title: l10n.t('ingredients'),
                      ),
                      const SizedBox(height: 8),
                      Text(recipe.ingredients),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        icon: Icons.notes_rounded,
                        title: l10n.t('steps'),
                      ),
                      const SizedBox(height: 8),
                      Text(recipe.steps),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('deleteRecipe')),
        content: Text(l10n.t('deleteRecipeConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(customRecipeRepositoryProvider).delete(recipe);
    if (context.mounted) context.go(AppRoutes.myRecipes);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _RecipeImage extends StatelessWidget {
  const _RecipeImage({required this.recipe});

  final CustomRecipe recipe;

  @override
  Widget build(BuildContext context) {
    if (recipe.imageUrl.isNotEmpty) {
      return SizedBox(
        height: 260,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: recipe.imageUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              const ColoredBox(color: Colors.black12),
        ),
      );
    }
    if (recipe.localImagePath.isNotEmpty) {
      return SizedBox(
        height: 260,
        width: double.infinity,
        child: Image.file(
          File(recipe.localImagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: Colors.black12),
        ),
      );
    }
    return const SizedBox(
      height: 220,
      width: double.infinity,
      child: ColoredBox(
        color: Colors.black12,
        child: Center(child: Icon(Icons.restaurant, size: 56)),
      ),
    );
  }
}
