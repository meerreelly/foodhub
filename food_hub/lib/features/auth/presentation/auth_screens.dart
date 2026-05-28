import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/app_header.dart';
import 'auth_controller.dart';

const _authBackgroundUrl =
    'https://images.unsplash.com/photo-1495195134817-aeb325a55b65'
    '?auto=format&fit=crop&w=1600&q=80';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthForm(
      titleKey: 'login',
      actionKey: 'login',
      showConfirm: false,
      onSubmit: (email, password) =>
          ref.read(authControllerProvider).signIn(email, password),
      footer: TextButton(
        onPressed: () => context.go(AppRoutes.register),
        child: Text(AppLocalizations.of(context).t('register')),
      ),
      secondary: TextButton(
        onPressed: () => context.go(AppRoutes.forgotPassword),
        child: Text(AppLocalizations.of(context).t('forgotPassword')),
      ),
    );
  }
}

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthForm(
      titleKey: 'register',
      actionKey: 'register',
      showConfirm: true,
      onSubmit: (email, password) =>
          ref.read(authControllerProvider).register(email, password),
      footer: TextButton(
        onPressed: () => context.go(AppRoutes.login),
        child: Text(AppLocalizations.of(context).t('login')),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppHeader(
        title: l10n.t('resetPassword'),
        icon: Icons.lock_reset_rounded,
        leading: IconButton(
          tooltip: l10n.t('login'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _AuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _AuthPanel(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(labelText: l10n.t('email')),
                        validator: (value) => _emailValidator(context, value),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() => _busy = true);
                                try {
                                  await ref
                                      .read(authControllerProvider)
                                      .resetPassword(_email.text.trim());
                                  if (context.mounted) {
                                    context.go(AppRoutes.login);
                                  }
                                } catch (error) {
                                  if (mounted) {
                                    setState(
                                      () => _error =
                                          localizedError(context, error),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _busy = false);
                                  }
                                }
                              },
                        child: Text(l10n.t('resetPassword')),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends ConsumerStatefulWidget {
  const _AuthForm({
    required this.titleKey,
    required this.actionKey,
    required this.showConfirm,
    required this.onSubmit,
    required this.footer,
    this.secondary,
  });

  final String titleKey;
  final String actionKey;
  final bool showConfirm;
  final Future<void> Function(String email, String password) onSubmit;
  final Widget footer;
  final Widget? secondary;

  @override
  ConsumerState<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: _AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _AuthPanel(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.t('appName'),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.t(widget.titleKey),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(labelText: l10n.t('email')),
                        validator: (value) => _emailValidator(context, value),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.t('password'),
                        ),
                        validator: (value) =>
                            _passwordValidator(context, value),
                      ),
                      if (widget.showConfirm) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirm,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.t('confirmPassword'),
                          ),
                          validator: (value) => value == _password.text
                              ? null
                              : l10n.t('passwordsDoNotMatch'),
                        ),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() => _busy = true);
                                try {
                                  await widget.onSubmit(
                                    _email.text.trim(),
                                    _password.text,
                                  );
                                  if (mounted) {
                                    setState(() => _error = null);
                                  }
                                } catch (error) {
                                  if (mounted) {
                                    setState(
                                      () => _error =
                                          localizedError(context, error),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _busy = false);
                                  }
                                }
                              },
                        child: _busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.t(widget.actionKey)),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      widget.footer,
                      if (widget.secondary != null) widget.secondary!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overlay = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.66)
        : Colors.white.withValues(alpha: 0.42);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          _authBackgroundUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            );
          },
        ),
        DecoratedBox(decoration: BoxDecoration(color: overlay)),
        child,
      ],
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

String? _emailValidator(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (!text.contains('@') || !text.contains('.')) {
    return AppLocalizations.of(context).t('invalidEmail');
  }
  return null;
}

String? _passwordValidator(BuildContext context, String? value) {
  if ((value ?? '').length < 6) {
    return AppLocalizations.of(context).t('passwordMinLength');
  }
  return null;
}
