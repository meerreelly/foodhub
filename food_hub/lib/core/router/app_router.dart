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
import '../../features/profile/presentation/account_screen.dart';
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
        pageBuilder: (context, state) =>
            _buildPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            _buildPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            _buildPage(state, const ForgotPasswordScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                _buildPage(state, const HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            pageBuilder: (context, state) =>
                _buildPage(state, const FavoritesScreen()),
          ),
          GoRoute(
            path: AppRoutes.addRecipe,
            pageBuilder: (context, state) =>
                _buildPage(state, const AddRecipeScreen()),
          ),
          GoRoute(
            path: AppRoutes.myRecipes,
            pageBuilder: (context, state) =>
                _buildPage(state, const MyRecipesScreen()),
          ),
          GoRoute(
            path: AppRoutes.mealPlan,
            pageBuilder: (context, state) =>
                _buildPage(state, const MealPlanScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                _buildPage(state, const SettingsScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                _buildPage(state, const ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.account,
            pageBuilder: (context, state) =>
                _buildPage(state, const AccountScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editCustomRecipePattern,
        pageBuilder: (context, state) => _buildPage(
          state,
          EditRecipeScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.customRecipePattern,
        pageBuilder: (context, state) => _buildPage(
          state,
          CustomRecipeDetailsScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.categoryPattern,
        pageBuilder: (context, state) => _buildPage(
          state,
          CategoryRecipesScreen(category: state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.recipePattern,
        pageBuilder: (context, state) => _buildPage(
          state,
          RecipeDetailsScreen(id: state.pathParameters['id']!),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).t('somethingWentWrong')),
      ),
    ),
  );
});

Page<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
