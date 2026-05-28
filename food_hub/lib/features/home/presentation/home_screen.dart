import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../meals/domain/meal.dart';
import '../../meals/presentation/meal_providers.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/async_value_view.dart';
import '../../shared/presentation/glass.dart';
import '../../shared/presentation/recipe_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();
  final _preferredIngredients = TextEditingController();
  SearchMode _mode = SearchMode.name;
  String _query = '';
  String? _category;
  double _maxIngredients = 12;
  var _filtersExpanded = false;

  @override
  void dispose() {
    _search.dispose();
    _preferredIngredients.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider);
    final random = ref.watch(randomMealProvider);
    final hasSearch = _query.isNotEmpty || _category != null;
    final results = ref.watch(
      searchMealsProvider(
        SearchQuery(query: _query, mode: _mode, category: _category),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(title: l10n.t('appName'), icon: Icons.restaurant_rounded),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(randomMealProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _search,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: l10n.t('searchHint'),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _runSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: l10n.t('searchParams'),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(46, 46),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => setState(
                          () => _filtersExpanded = !_filtersExpanded,
                        ),
                        icon: Icon(
                          _filtersExpanded
                              ? Icons.tune_rounded
                              : Icons.tune_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_filtersExpanded) ...[
              const SizedBox(height: 10),
              GlassPanel(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<SearchMode>(
                      segments: [
                        ButtonSegment(
                          value: SearchMode.name,
                          icon: const Icon(Icons.restaurant_menu_rounded),
                          label: Text(l10n.t('searchByName')),
                        ),
                        ButtonSegment(
                          value: SearchMode.ingredient,
                          icon: const Icon(Icons.eco_rounded),
                          label: Text(l10n.t('searchByIngredient')),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (value) =>
                          setState(() => _mode = value.first),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: l10n.t('category'),
                        prefixIcon: const Icon(Icons.category_rounded),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.t('allCategories')),
                        ),
                        ...categories.valueOrNull
                                ?.map(
                                  (item) => DropdownMenuItem(
                                    value: item.name,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList() ??
                            const [],
                      ],
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _preferredIngredients,
                      decoration: InputDecoration(
                        labelText: l10n.t('preferredIngredients'),
                        prefixIcon: const Icon(Icons.spa_rounded),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _runSearch(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.t('maxIngredients')}: ${_maxIngredients.round()}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Slider(
                      value: _maxIngredients,
                      min: 3,
                      max: 20,
                      divisions: 17,
                      label: _maxIngredients.round().toString(),
                      onChanged: (value) =>
                          setState(() => _maxIngredients = value),
                    ),
                  ],
                ),
              ),
            ],
            if (hasSearch) ...[
              const SizedBox(height: 10),
              _RecipeResults(value: results),
            ],
            const SizedBox(height: 10),
            Text(
              l10n.t('recipeOfDay'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            AsyncValueView<Meal>(
              value: random,
              retry: () => ref.invalidate(randomMealProvider),
              data: (meal) => _RandomMealCard(meal: meal),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.t('categories'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            AsyncValueView(
              value: categories,
              retry: () => ref.invalidate(categoriesProvider),
              data: (items) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) =>
                    _CategoryCard(category: items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runSearch() {
    final preferred = _preferredIngredients.text.trim();
    setState(() {
      _query = _search.text.trim().isEmpty ? preferred : _search.text.trim();
    });
  }
}

class _RecipeResults extends StatelessWidget {
  const _RecipeResults({required this.value});

  final AsyncValue<List<MealSummary>> value;

  @override
  Widget build(BuildContext context) {
    return AsyncValueView(
      value: value,
      data: (items) {
        if (items.isEmpty) {
          return Text(AppLocalizations.of(context).t('emptyResults'));
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => RecipeCard(meal: items[index]),
        );
      },
    );
  }
}

class _RandomMealCard extends StatelessWidget {
  const _RandomMealCard({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(AppRoutes.recipe(meal.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'meal-${meal.id}',
              child: CachedNetworkImage(
                imageUrl: meal.thumbnailUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                meal.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category});

  final MealCategory category;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      transform: Matrix4.identity()
        ..scaleByDouble(_pressed ? .97 : 1.0, _pressed ? .97 : 1.0, 1, 1),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            setState(() => _pressed = false);
            context.push(AppRoutes.category(widget.category.name));
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.category.thumbnailUrl,
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .32),
                ),
              ),
              Center(
                child: Text(
                  widget.category.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
