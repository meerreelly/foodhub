import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/glass.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(title: l10n.t('profile'), icon: Icons.person_rounded),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          GlassPanel(
            padding: EdgeInsets.zero,
            child: _ProfileLink(
              icon: Icons.account_circle_rounded,
              title: l10n.t('account'),
              onTap: () => context.go(AppRoutes.account),
            ),
          ),
          const SizedBox(height: 10),
          GlassPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _ProfileLink(
                  icon: Icons.calendar_month_rounded,
                  title: l10n.t('mealPlan'),
                  onTap: () => context.go(AppRoutes.mealPlan),
                ),
                _ProfileLink(
                  icon: Icons.menu_book_rounded,
                  title: l10n.t('myRecipes'),
                  onTap: () => context.go(AppRoutes.myRecipes),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileLink(
                  icon: Icons.settings_rounded,
                  title: l10n.t('settings'),
                  onTap: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}
