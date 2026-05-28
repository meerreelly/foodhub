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
      _ => 0,
    };
    final profileSelected = switch (location) {
      AppRoutes.profile ||
      AppRoutes.mealPlan ||
      AppRoutes.settings ||
      AppRoutes.account =>
        true,
      _ => false,
    };
    final isLight = Theme.of(context).brightness == Brightness.light;
    final navigationColor = isLight
        ? const Color(0xFFE0E7DE).withValues(alpha: 0.92)
        : Colors.transparent;
    final navigationBorderColor = isLight
        ? const Color(0xFF7B897F).withValues(alpha: 0.38)
        : Colors.transparent;

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
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: navigationColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: navigationBorderColor),
                      boxShadow: isLight
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          _ShellTab(
                            icon: Icons.home_rounded,
                            label: l10n.t('home'),
                            selected: !profileSelected && index == 0,
                            onTap: () => context.go(AppRoutes.home),
                          ),
                          _ShellTab(
                            icon: Icons.favorite_rounded,
                            label: l10n.t('favorites'),
                            selected: !profileSelected && index == 1,
                            onTap: () => context.go(AppRoutes.favorites),
                          ),
                          _ShellTab(
                            icon: Icons.menu_book_rounded,
                            label: l10n.t('myRecipes'),
                            selected: !profileSelected && index == 2,
                            onTap: () => context.go(AppRoutes.myRecipes),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: navigationColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: navigationBorderColor),
                    boxShadow: isLight
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.all(6),
                    child: _ProfileTab(
                      label: l10n.t('profile'),
                      selected: profileSelected,
                      onTap: () => context.go(AppRoutes.profile),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellTab extends StatelessWidget {
  const _ShellTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final foreground = selected
        ? (isLight ? const Color(0xFF062D22) : colorScheme.onPrimaryContainer)
        : (isLight ? const Color(0xFF26342D) : colorScheme.onSurfaceVariant);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? (isLight
                        ? const Color(0xFFBFE8D7).withValues(alpha: 0.96)
                        : colorScheme.primaryContainer.withValues(alpha: 0.82))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final foreground = selected
        ? (isLight ? const Color(0xFF062D22) : colorScheme.onPrimaryContainer)
        : (isLight ? const Color(0xFF26342D) : colorScheme.onSurfaceVariant);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 68,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? (isLight
                        ? const Color(0xFFBFE8D7).withValues(alpha: 0.96)
                        : colorScheme.primaryContainer.withValues(alpha: 0.82))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.person_rounded, color: foreground, size: 26),
          ),
        ),
      ),
    );
  }
}
