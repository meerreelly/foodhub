class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const favorites = '/favorites';
  static const addRecipe = '/add-recipe';
  static const myRecipes = '/my-recipes';
  static const mealPlan = '/meal-plan';
  static const settings = '/settings';
  static const profile = '/profile';
  static const account = '/account';

  static const customRecipePattern = '/my-recipes/:id';
  static const editCustomRecipePattern = '/my-recipes/:id/edit';
  static const categoryPattern = '/category/:name';
  static const recipePattern = '/recipe/:id';

  static String category(String name) =>
      '/category/${Uri.encodeComponent(name)}';
  static String recipe(String id) => '/recipe/$id';
  static String customRecipe(String id) => '/my-recipes/$id';
  static String editCustomRecipe(String id) => '/my-recipes/$id/edit';
}
