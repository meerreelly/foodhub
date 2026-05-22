import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../shared/presentation/async_value_view.dart';
import '../domain/meal.dart';
import 'meal_providers.dart';

class RecipeDetailsScreen extends ConsumerWidget {
  const RecipeDetailsScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meal = ref.watch(mealDetailsProvider(id));
    return Scaffold(
      body: AsyncValueView<Meal>(
        value: meal,
        retry: () => ref.invalidate(mealDetailsProvider(id)),
        data: (item) => _DetailsBody(meal: item),
      ),
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          actions: [
            IconButton(
              onPressed: () => ref.read(favoritesRepositoryProvider).toggle(meal),
              icon: const Icon(Icons.favorite_border),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(meal.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            background: Hero(
              tag: 'meal-${meal.id}',
              child: CachedNetworkImage(imageUrl: meal.thumbnailUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(18),
          sliver: SliverList.list(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (meal.category.isNotEmpty) Chip(label: Text(meal.category)),
                  if (meal.area.isNotEmpty) Chip(label: Text(meal.area)),
                ],
              ),
              const SizedBox(height: 18),
              Text(l10n.t('ingredients'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...meal.ingredients.map((item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(item.ingredient),
                    trailing: Text(item.measure),
                  )),
              const SizedBox(height: 18),
              Text(l10n.t('instructions'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(meal.instructions),
              if (meal.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => launchUrl(Uri.parse(meal.youtubeUrl), mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(l10n.t('watchVideo')),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
