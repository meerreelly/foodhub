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
      AppRoutes.myRecipes => 2,
      AppRoutes.addRecipe => 2,
      AppRoutes.profile => 3,
      AppRoutes.mealPlan => 3,
      AppRoutes.settings => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: Row(
          children: [
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  children: [
                    _ShellTab(
                      selected: index == 0,
                      icon: Icons.home_rounded,
                      label: l10n.t('home'),
                      onTap: () => context.go(AppRoutes.home),
                    ),
                    _ShellTab(
                      selected: index == 1,
                      icon: Icons.favorite_rounded,
                      label: l10n.t('favorites'),
                      onTap: () => context.go(AppRoutes.favorites),
                    ),
                    _ShellTab(
                      selected: index == 2,
                      icon: Icons.menu_book_rounded,
                      label: l10n.t('myRecipes'),
                      onTap: () => context.go(AppRoutes.myRecipes),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GlassPanel(
              padding: const EdgeInsets.all(8),
              child: IconButton.filledTonal(
                isSelected: index == 3,
                tooltip: l10n.t('profile'),
                onPressed: () => context.go(AppRoutes.profile),
                icon: const Icon(Icons.person_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellTab extends StatelessWidget {
  const _ShellTab({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: .70)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
