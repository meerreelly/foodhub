import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/glass.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(
        title: l10n.t('addRecipe'),
        icon: Icons.add_circle_rounded,
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
                  PopupMenuButton<ImageSource>(
                    onSelected: _pick,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: ImageSource.gallery,
                        child: ListTile(
                          leading: const Icon(Icons.photo_library_rounded),
                          title: Text(l10n.t('pickGallery')),
                        ),
                      ),
                      PopupMenuItem(
                        value: ImageSource.camera,
                        child: ListTile(
                          leading: const Icon(Icons.camera_alt_rounded),
                          title: Text(l10n.t('pickCamera')),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded),
                          const SizedBox(width: 8),
                          Text(l10n.t('choosePhoto')),
                          const SizedBox(width: 6),
                          const Icon(Icons.expand_more_rounded),
                        ],
                      ),
                    ),
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
                    icon: const Icon(Icons.save_rounded),
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
      if (mounted) context.go(AppRoutes.myRecipes);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedError(context, error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => (value?.trim().isEmpty ?? true)
      ? AppLocalizations.of(context).t('requiredField')
      : null;
}
