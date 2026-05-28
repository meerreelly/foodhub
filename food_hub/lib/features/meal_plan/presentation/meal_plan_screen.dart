import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/glass.dart';
import '../data/meal_plan_repository.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  static const _dayKeys = [
    'mondayShort',
    'tuesdayShort',
    'wednesdayShort',
    'thursdayShort',
    'fridayShort',
    'saturdayShort',
    'sundayShort',
  ];
  static const _slots = ['breakfast', 'lunch', 'dinner'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favorites = ref.watch(favoritesProvider);
    final plan = ref.watch(mealPlanProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(
        title: l10n.t('mealPlan'),
        icon: Icons.calendar_month_rounded,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.profile),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(localizedError(context, error))),
        data: (items) {
          final favoriteItems = favorites.valueOrNull ?? const <FavoriteMeal>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
            children: [
              if (favoriteItems.isEmpty)
                GlassPanel(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.favorite_border, size: 22),
                    title: Text(l10n.t('noFavoritesForPlan')),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.go(AppRoutes.favorites),
                  ),
                ),
              if (favoriteItems.isEmpty) const SizedBox(height: 10),
              ..._dayKeys.map((dayKey) {
                final day = l10n.t(dayKey);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                    child: ExpansionTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      childrenPadding: const EdgeInsets.only(bottom: 4),
                      leading: const Icon(
                        Icons.calendar_today_rounded,
                        size: 22,
                      ),
                      title: Text(day),
                      initiallyExpanded: dayKey == _dayKeys.first,
                      children: _slots.map((slot) {
                        final entry = _entryFor(items, dayKey, slot);
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          title: Text(l10n.t(slot)),
                          subtitle: Text(entry?.name ?? l10n.t('emptySlot')),
                          trailing: favoriteItems.isEmpty
                              ? null
                              : PopupMenuButton<FavoriteMeal>(
                                  icon: const Icon(Icons.add, size: 22),
                                  onSelected: (meal) => ref
                                      .read(mealPlanRepositoryProvider)
                                      .setSlot(dayKey, slot, meal),
                                  itemBuilder: (context) => favoriteItems
                                      .map(
                                        (meal) => PopupMenuItem(
                                          value: meal,
                                          child: Text(meal.name),
                                        ),
                                      )
                                      .toList(),
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  MealPlanEntry? _entryFor(List<MealPlanEntry> items, String day, String slot) {
    for (final item in items) {
      if (item.day == day && item.slot == slot) return item;
    }
    return null;
  }
}
