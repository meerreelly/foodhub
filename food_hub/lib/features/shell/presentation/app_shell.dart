import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      AppRoutes.favorites => 1,
      AppRoutes.myRecipes => 2,
      AppRoutes.addRecipe => 2,
      AppRoutes.profile => 3,
      AppRoutes.mealPlan => 3,
      AppRoutes.settings => 3,
      AppRoutes.account => 3,
      _ => 0,
    };

    return GlassPage(
      background: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [
                    Color(0xFF101614),
                    Color(0xFF16201D),
                    Color(0xFF0D1417),
                  ]
                : const [
                    Color(0xFFF8FBF7),
                    Color(0xFFEFF7F2),
                    Color(0xFFF5F4EE),
                  ],
          ),
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: GlassBottomBar(
            tabs: [
              GlassBottomBarTab(
                icon: const Icon(Icons.home_rounded),
                label: l10n.t('home'),
              ),
              GlassBottomBarTab(
                icon: const Icon(Icons.favorite_rounded),
                label: l10n.t('favorites'),
              ),
              GlassBottomBarTab(
                icon: const Icon(Icons.menu_book_rounded),
                label: l10n.t('myRecipes'),
              ),
              GlassBottomBarTab(
                icon: const Icon(Icons.person_rounded),
                label: l10n.t('profile'),
              ),
            ],
            selectedIndex: index,
            onTabSelected: (value) {
              final path = [
                AppRoutes.home,
                AppRoutes.favorites,
                AppRoutes.myRecipes,
                AppRoutes.profile,
              ][value];
              context.go(path);
            },
          ),
        ),
      ),
    );
  }
}
