import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/database_tables.dart';
import '../../../core/firebase/firebase_status.dart';
import '../../../core/storage/local_database.dart';
import '../../auth/presentation/auth_controller.dart';

final customRecipeRepositoryProvider = Provider<CustomRecipeRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return CustomRecipeRepository(
    firebaseReady: ref.watch(firebaseReadyProvider),
    uid: user?.uid,
  );
});

class CustomRecipe {
  const CustomRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.localImagePath,
  });

  final String id;
  final String title;
  final String category;
  final String ingredients;
  final String steps;
  final String imageUrl;
  final String localImagePath;

  CustomRecipe copyWith({
    String? title,
    String? category,
    String? ingredients,
    String? steps,
    String? imageUrl,
    String? localImagePath,
  }) {
    return CustomRecipe(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  factory CustomRecipe.fromJson(String id, Map<String, dynamic> json) {
    return CustomRecipe(
      id: id,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      ingredients: json['ingredients']?.toString() ?? '',
      steps: json['steps']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      localImagePath: json['localImagePath']?.toString() ?? '',
    );
  }

  Map<String, Object?> toRemoteJson(String imageUrl) => {
    'title': title,
    'category': category,
    'ingredients': ingredients,
    'steps': steps,
    'imageUrl': imageUrl,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, Object?> toLocalJson(
    String syncStatus, {
    String? remoteImageUrl,
  }) => {
    'id': id,
    'title': title,
    'category': category,
    'ingredients': ingredients,
    'steps': steps,
    'imageUrl': remoteImageUrl ?? imageUrl,
    'localImagePath': localImagePath,
    'syncStatus': syncStatus,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  };
}

class CustomRecipeRepository {
  CustomRecipeRepository({required this._firebaseReady, required this._uid});

  final bool _firebaseReady;
  final String? _uid;
  final _controller = StreamController<List<CustomRecipe>>.broadcast();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteSubscription;

  Stream<List<CustomRecipe>> watchMine() {
    _loadLocal();
    if (_canSync) {
      _syncPending();
      _remoteSubscription ??= _remoteCollection
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .listen((snapshot) async {
            final db = await LocalDatabase.instance.database;
            final batch = db.batch();
            final remoteIds = <String>{};
            for (final doc in snapshot.docs) {
              final recipe = CustomRecipe.fromJson(doc.id, doc.data());
              remoteIds.add(recipe.id);
              if (await _hasPendingLocal(db, recipe.id)) {
                continue;
              }
              batch.insert(
                DatabaseTables.customRecipes,
                recipe.toLocalJson(SyncStatus.synced),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            await _deleteSyncedRowsMissingRemotely(db, remoteIds);
            await batch.commit(noResult: true);
            await _loadLocal();
          });
    }
    return _controller.stream;
  }

  Future<void> create({
    required String title,
    required String category,
    required String ingredients,
    required String steps,
    File? image,
  }) async {
    final recipe = CustomRecipe(
      id: const Uuid().v4(),
      title: title,
      category: category,
      ingredients: ingredients,
      steps: steps,
      imageUrl: '',
      localImagePath: image?.path ?? '',
    );
    final db = await LocalDatabase.instance.database;
    await db.insert(
      DatabaseTables.customRecipes,
      recipe.toLocalJson(SyncStatus.pending),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _loadLocal();
    if (_canSync) {
      try {
        await _uploadAndSave(recipe);
      } catch (_) {
        // Keep the local pending row visible; the next sync pass can retry.
      } finally {
        await _loadLocal();
      }
    }
  }

  Future<void> update(CustomRecipe recipe, {File? image}) async {
    final updated = recipe.copyWith(
      imageUrl: image == null ? recipe.imageUrl : '',
      localImagePath: image?.path ?? recipe.localImagePath,
    );
    final db = await LocalDatabase.instance.database;
    await db.insert(
      DatabaseTables.customRecipes,
      updated.toLocalJson(SyncStatus.pending),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _loadLocal();
    if (_canSync) {
      try {
        await _uploadAndSave(updated);
      } catch (_) {
        // Keep the local pending row visible; the next sync pass can retry.
      } finally {
        await _loadLocal();
      }
    }
  }

  Future<void> delete(CustomRecipe recipe) async {
    final db = await LocalDatabase.instance.database;
    await db.update(
      DatabaseTables.customRecipes,
      {
        'syncStatus': SyncStatus.pendingDelete,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
    await _loadLocal();
    if (_canSync) {
      try {
        await _remoteCollection.doc(recipe.id).delete();
        await db.delete(
          DatabaseTables.customRecipes,
          where: 'id = ?',
          whereArgs: [recipe.id],
        );
      } finally {
        await _loadLocal();
      }
    }
    await _loadLocal();
  }

  Future<void> _loadLocal() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.customRecipes,
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.pendingDelete],
      orderBy: 'updatedAt DESC',
    );
    _controller.add(
      rows
          .map((row) => CustomRecipe.fromJson(row['id'].toString(), row))
          .toList(),
    );
  }

  Future<void> _syncPending() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.customRecipes,
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.synced],
    );
    for (final row in rows) {
      final recipe = CustomRecipe.fromJson(row['id'].toString(), row);
      if (row['syncStatus'] == SyncStatus.pendingDelete) {
        try {
          await _remoteCollection.doc(recipe.id).delete();
          await db.delete(
            DatabaseTables.customRecipes,
            where: 'id = ?',
            whereArgs: [recipe.id],
          );
        } catch (_) {
          // Keep the pending delete marker for the next sync pass.
        }
      } else {
        try {
          await _uploadAndSave(recipe);
        } catch (_) {
          // Keep the pending row for the next sync pass.
        }
      }
    }
    await _loadLocal();
  }

  Future<bool> _hasPendingLocal(Database db, String id) async {
    final rows = await db.query(
      DatabaseTables.customRecipes,
      columns: ['syncStatus'],
      where: 'id = ? AND syncStatus != ?',
      whereArgs: [id, SyncStatus.synced],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> _deleteSyncedRowsMissingRemotely(
    Database db,
    Set<String> remoteIds,
  ) async {
    if (remoteIds.isEmpty) {
      await db.delete(
        DatabaseTables.customRecipes,
        where: 'syncStatus = ?',
        whereArgs: [SyncStatus.synced],
      );
      return;
    }
    await db.delete(
      DatabaseTables.customRecipes,
      where:
          'syncStatus = ? AND id NOT IN (${List.filled(remoteIds.length, '?').join(',')})',
      whereArgs: [SyncStatus.synced, ...remoteIds],
    );
  }

  Future<void> _uploadAndSave(CustomRecipe recipe) async {
    var imageUrl = recipe.imageUrl;
    if (recipe.localImagePath.isNotEmpty && imageUrl.isEmpty) {
      final ref = FirebaseStorage.instance.ref(
        'users/$_uid/custom_recipes/${recipe.id}.jpg',
      );
      await ref.putFile(File(recipe.localImagePath));
      imageUrl = await ref.getDownloadURL();
    }
    await _remoteCollection.doc(recipe.id).set(recipe.toRemoteJson(imageUrl));
    final db = await LocalDatabase.instance.database;
    await db.update(
      DatabaseTables.customRecipes,
      {
        'syncStatus': SyncStatus.synced,
        'imageUrl': imageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  bool get _canSync => _firebaseReady && _uid != null;

  CollectionReference<Map<String, dynamic>> get _remoteCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('custom_recipes');
  }

  Future<void> dispose() async {
    await _remoteSubscription?.cancel();
    await _controller.close();
  }
}

final myRecipesProvider = StreamProvider<List<CustomRecipe>>((ref) {
  final repository = ref.watch(customRecipeRepositoryProvider);
  ref.onDispose(repository.dispose);
  return repository.watchMine();
});
