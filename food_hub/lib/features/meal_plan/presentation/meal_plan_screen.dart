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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              if (favoriteItems.isEmpty)
                GlassPanel(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.favorite_border),
                    title: Text(l10n.t('noFavoritesForPlan')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(AppRoutes.favorites),
                  ),
                ),
              const SizedBox(height: 8),
              ..._dayKeys.map((dayKey) {
                final day = l10n.t(dayKey);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: Text(day),
                    initiallyExpanded: dayKey == _dayKeys.first,
                    children: _slots.map((slot) {
                      final entry = _entryFor(items, dayKey, slot);
                      return ListTile(
                        title: Text(l10n.t(slot)),
                        subtitle: Text(entry?.name ?? l10n.t('emptySlot')),
                        trailing: favoriteItems.isEmpty
                            ? null
                            : PopupMenuButton<FavoriteMeal>(
                                icon: const Icon(Icons.add),
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
