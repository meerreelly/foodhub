import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../shared/presentation/async_value_view.dart';
import '../../shared/presentation/glass.dart';
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
    final favoriteIds = ref
            .watch(favoritesProvider)
            .valueOrNull
            ?.map((item) => item.id)
            .toSet() ??
        const <String>{};
    final isFavorite = favoriteIds.contains(meal.id);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton.filledTonal(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          title: Text(meal.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                onPressed: () => ref.read(favoritesRepositoryProvider).toggle(meal),
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.green : null,
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Hero(
            tag: 'meal-${meal.id}',
            child: CachedNetworkImage(
              imageUrl: meal.thumbnailUrl,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
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
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.checklist_rounded,
                      title: l10n.t('ingredients'),
                    ),
                    const SizedBox(height: 8),
                    ...meal.ingredients.map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline_rounded),
                        title: Text(item.ingredient),
                        trailing: Text(item.measure),
                      ),
                    ),
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
                      title: l10n.t('instructions'),
                    ),
                    const SizedBox(height: 10),
                    Text(meal.instructions),
                  ],
                ),
              ),
              if (meal.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(meal.youtubeUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.play_circle_outline_rounded),
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
