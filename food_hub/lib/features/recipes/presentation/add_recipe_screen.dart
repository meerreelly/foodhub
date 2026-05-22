import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/custom_recipe_repository.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  File? _image;
  var _saving = false;

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
    final mine = ref.watch(myRecipesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('addRecipe')),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.myRecipes),
            icon: const Icon(Icons.list_alt),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Form(
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
                  decoration: InputDecoration(labelText: l10n.t('ingredients')),
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
          const SizedBox(height: 24),
          Text(
            l10n.t('myRecipes'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          mine.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(localizedError(context, error)),
            data: (items) => Column(
              children: items
                  .map(
                    (recipe) => ListTile(
                      title: Text(recipe.title),
                      subtitle: Text(recipe.category),
                      leading: const Icon(Icons.restaurant),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.push(AppRoutes.customRecipe(recipe.id)),
                    ),
                  )
                  .toList(),
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
      await ref
          .read(customRecipeRepositoryProvider)
          .create(
            title: _title.text.trim(),
            category: _category.text.trim(),
            ingredients: _ingredients.text.trim(),
            steps: _steps.text.trim(),
            image: _image,
          );
      _formKey.currentState!.reset();
      _title.clear();
      _category.clear();
      _ingredients.clear();
      _steps.clear();
      setState(() => _image = null);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => (value?.trim().isEmpty ?? true)
      ? AppLocalizations.of(context).t('requiredField')
      : null;
}
