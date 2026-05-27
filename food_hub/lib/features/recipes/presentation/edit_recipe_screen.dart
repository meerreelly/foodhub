import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/glass.dart';
import '../data/custom_recipe_repository.dart';

class EditRecipeScreen extends ConsumerWidget {
  const EditRecipeScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(myRecipesProvider);
    return recipes.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text(localizedError(context, error))),
          ),
      data: (items) {
        for (final recipe in items) {
          if (recipe.id == id) return _EditRecipeForm(recipe: recipe);
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(),
          body: Center(
            child: Text(AppLocalizations.of(context).t('recipeNotFound')),
          ),
        );
      },
    );
  }
}

class _EditRecipeForm extends ConsumerStatefulWidget {
  const _EditRecipeForm({required this.recipe});

  final CustomRecipe recipe;

  @override
  ConsumerState<_EditRecipeForm> createState() => _EditRecipeFormState();
}

class _EditRecipeFormState extends ConsumerState<_EditRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _category;
  late final TextEditingController _ingredients;
  late final TextEditingController _steps;
  File? _image;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.recipe.title);
    _category = TextEditingController(text: widget.recipe.category);
    _ingredients = TextEditingController(text: widget.recipe.ingredients);
    _steps = TextEditingController(text: widget.recipe.steps);
  }

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _ingredients.dispose();
    _steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(
        title: l10n.t('editRecipe'),
        icon: Icons.edit_rounded,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          GlassPanel(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  if (_image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: Text(l10n.t('pickGallery')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: Text(l10n.t('pickCamera')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(labelText: l10n.t('title')),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _category,
                    decoration: InputDecoration(labelText: l10n.t('category')),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ingredients,
                    decoration: InputDecoration(
                      labelText: l10n.t('ingredients'),
                    ),
                    minLines: 3,
                    maxLines: 5,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _steps,
                    decoration: InputDecoration(labelText: l10n.t('steps')),
                    minLines: 4,
                    maxLines: 8,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.t('save')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final recipe = widget.recipe.copyWith(
        title: _title.text.trim(),
        category: _category.text.trim(),
        ingredients: _ingredients.text.trim(),
        steps: _steps.text.trim(),
      );
      await ref
          .read(customRecipeRepositoryProvider)
          .update(recipe, image: _image);
      if (mounted) context.go(AppRoutes.customRecipe(widget.recipe.id));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) {
    return (value?.trim().isEmpty ?? true)
        ? AppLocalizations.of(context).t('requiredField')
        : null;
  }
}
