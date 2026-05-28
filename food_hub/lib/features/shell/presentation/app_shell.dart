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
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final tabColor = isLight ? const Color(0xFF17211C) : null;
    final activeTabColor = isLight ? const Color(0xFF0B120F) : null;
    final bottomBarTheme = isLight
        ? theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xFF0B120F),
              onPrimary: const Color(0xFF0B120F),
              onSurface: const Color(0xFF0B120F),
              onSurfaceVariant: const Color(0xFF17211C),
              inverseSurface: const Color(0xFF0B120F),
              onInverseSurface: const Color(0xFF0B120F),
            ),
            textTheme: theme.textTheme.apply(
              bodyColor: const Color(0xFF17211C),
              displayColor: const Color(0xFF17211C),
            ),
            iconTheme: theme.iconTheme.copyWith(color: const Color(0xFF17211C)),
          )
        : theme;
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
          child: Theme(
            data: bottomBarTheme,
            child: IconTheme(
              data: bottomBarTheme.iconTheme.copyWith(color: tabColor),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: tabColor),
                child: GlassBottomBar(
                  tabs: [
                    GlassBottomBarTab(
                      icon: Icon(Icons.home_rounded, color: tabColor),
                      activeIcon: Icon(
                        Icons.home_rounded,
                        color: activeTabColor,
                      ),
                      label: l10n.t('home'),
                    ),
                    GlassBottomBarTab(
                      icon: Icon(Icons.favorite_rounded, color: tabColor),
                      activeIcon: Icon(
                        Icons.favorite_rounded,
                        color: activeTabColor,
                      ),
                      label: l10n.t('favorites'),
                    ),
                    GlassBottomBarTab(
                      icon: Icon(Icons.menu_book_rounded, color: tabColor),
                      activeIcon: Icon(
                        Icons.menu_book_rounded,
                        color: activeTabColor,
                      ),
                      label: l10n.t('myRecipes'),
                    ),
                    GlassBottomBarTab(
                      icon: Icon(Icons.person_rounded, color: tabColor),
                      activeIcon: Icon(
                        Icons.person_rounded,
                        color: activeTabColor,
                      ),
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
          ),
        ),
      ),
    );
  }
}
