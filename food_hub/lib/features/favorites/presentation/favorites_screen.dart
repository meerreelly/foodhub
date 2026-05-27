import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/glass.dart';
import '../data/favorites_repository.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('favorites'))),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(localizedError(context, error))),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.t('emptyFavorites')));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final meal = items[index];
              return GlassPanel(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(meal.thumbnailUrl),
                  ),
                  title: Text(meal.name),
                  subtitle: Text(meal.category),
                  trailing: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.green,
                  ),
                  onTap: () => context.push(AppRoutes.recipe(meal.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
