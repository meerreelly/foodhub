import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_hub/core/l10n/app_localizations.dart';
import 'package:food_hub/features/recipes/data/custom_recipe_repository.dart';
import 'package:food_hub/features/recipes/presentation/add_recipe_screen.dart';

void main() {
  testWidgets('AddRecipeScreen validates required fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myRecipesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: AddRecipeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(find.text('Save', skipOffstage: false));
    await tester.tap(find.text('Save', skipOffstage: false));
    await tester.pump();

    expect(find.text('This field is required'), findsWidgets);
  });
}
