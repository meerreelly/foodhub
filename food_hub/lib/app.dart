import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_controller.dart';

class FoodHubApp extends ConsumerWidget {
  const FoodHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FoodHub',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: Locale(settings.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return _KeyboardDismissScope(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _KeyboardDismissScope extends StatefulWidget {
  const _KeyboardDismissScope({required this.child});

  final Widget child;

  @override
  State<_KeyboardDismissScope> createState() => _KeyboardDismissScopeState();
}

class _KeyboardDismissScopeState extends State<_KeyboardDismissScope> {
  final Map<int, double> _downwardDragByPointer = {};

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _downwardDragByPointer[event.pointer] = 0;
      },
      onPointerMove: (event) {
        if (event.delta.dy <= 0) return;

        final drag = (_downwardDragByPointer[event.pointer] ?? 0) +
            event.delta.dy;
        _downwardDragByPointer[event.pointer] = drag;

        if (drag > 16) {
          _hideKeyboard();
        }
      },
      onPointerUp: (event) {
        _downwardDragByPointer.remove(event.pointer);
      },
      onPointerCancel: (event) {
        _downwardDragByPointer.remove(event.pointer);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideKeyboard,
        child: widget.child,
      ),
    );
  }

  void _hideKeyboard() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasFocus) return;
    focus.unfocus();
  }
}
