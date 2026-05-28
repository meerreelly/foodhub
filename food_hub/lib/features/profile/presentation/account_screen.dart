import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/glass.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(
        title: l10n.t('account'),
        icon: Icons.account_circle_rounded,
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.profile),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          GlassPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.mail_rounded, size: 22),
                  title: Text(
                    l10n.t('email'),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  subtitle: Text(
                    user?.email ?? l10n.t('notSignedIn'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const Divider(height: 18),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.password_rounded, size: 22),
                  title: Text(l10n.t('editPassword')),
                  subtitle: Text(l10n.t('resetPasswordHint')),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: user == null
                      ? null
                      : () => _resetPassword(context, ref, user.email),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => ref.read(authControllerProvider).signOut(),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.t('logout')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword(
    BuildContext context,
    WidgetRef ref,
    String email,
  ) async {
    try {
      await ref.read(authControllerProvider).resetPassword(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).t('resetSent'))),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedError(context, error))),
      );
    }
  }
}
