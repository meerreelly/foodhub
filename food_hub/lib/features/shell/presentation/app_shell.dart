import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/glass.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      AppRoutes.favorites => 1,
      AppRoutes.addRecipe => 2,
      AppRoutes.myRecipes => 2,
      AppRoutes.profile => 3,
      AppRoutes.mealPlan => 3,
      AppRoutes.settings => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: GlassPanel(
          padding: EdgeInsets.zero,
          child: NavigationBar(
            selectedIndex: index,
            backgroundColor: Colors.transparent,
            onDestinationSelected: (value) {
              final path = [
                AppRoutes.home,
                AppRoutes.favorites,
                AppRoutes.addRecipe,
                AppRoutes.profile,
              ][value];
              context.go(path);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.t('home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: l10n.t('favorites'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.add_circle_outline),
                selectedIcon: const Icon(Icons.add_circle),
                label: l10n.t('addRecipe'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.t('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
