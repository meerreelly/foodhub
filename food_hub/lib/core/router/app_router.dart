import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/category_recipes_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/meal_plan/presentation/meal_plan_screen.dart';
import '../../features/meals/presentation/recipe_details_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/recipes/presentation/add_recipe_screen.dart';
import '../../features/recipes/presentation/custom_recipe_details_screen.dart';
import '../../features/recipes/presentation/edit_recipe_screen.dart';
import '../../features/recipes/presentation/my_recipes_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../constants/app_routes.dart';
import '../l10n/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  final loggedIn = auth.valueOrNull != null;

  return GoRouter(
    initialLocation: loggedIn ? AppRoutes.home : AppRoutes.login,
    redirect: (context, state) {
      final authPath =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;
      if (!loggedIn && !authPath) return AppRoutes.login;
      if (loggedIn && authPath) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.addRecipe,
            builder: (context, state) => const AddRecipeScreen(),
          ),
          GoRoute(
            path: AppRoutes.myRecipes,
            builder: (context, state) => const MyRecipesScreen(),
          ),
          GoRoute(
            path: AppRoutes.mealPlan,
            builder: (context, state) => const MealPlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editCustomRecipePattern,
        builder: (context, state) =>
            EditRecipeScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.customRecipePattern,
        builder: (context, state) =>
            CustomRecipeDetailsScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.categoryPattern,
        builder: (context, state) =>
            CategoryRecipesScreen(category: state.pathParameters['name']!),
      ),
      GoRoute(
        path: AppRoutes.recipePattern,
        builder: (context, state) =>
            RecipeDetailsScreen(id: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).t('somethingWentWrong')),
      ),
    ),
  );
});
