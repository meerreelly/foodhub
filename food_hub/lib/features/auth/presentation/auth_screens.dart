import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/app_header.dart';
import 'auth_controller.dart';

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
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                                  () => _error = localizedError(context, error),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.t('appName'),
                    style: Theme.of(context).textTheme.displaySmall,
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
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.t('password')),
                    validator: (value) => _passwordValidator(context, value),
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
                                  () => _error = localizedError(context, error),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
