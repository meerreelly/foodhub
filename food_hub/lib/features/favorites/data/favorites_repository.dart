import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/database_tables.dart';
import '../../../core/firebase/firebase_status.dart';
import '../../../core/storage/local_database.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../meals/domain/meal.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return FavoritesRepository(
    firebaseReady: ref.watch(firebaseReadyProvider),
    uid: user?.uid,
  );
});

class FavoriteMeal {
  const FavoriteMeal({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.category,
  });

  final String id;
  final String name;
  final String thumbnailUrl;
  final String category;

  factory FavoriteMeal.fromMeal(Meal meal) {
    return FavoriteMeal(
      id: meal.id,
      name: meal.name,
      thumbnailUrl: meal.thumbnailUrl,
      category: meal.category,
    );
  }

  factory FavoriteMeal.fromJson(Map<String, dynamic> json) {
    return FavoriteMeal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'category': category,
    'savedAt': FieldValue.serverTimestamp(),
  };

  Map<String, Object?> toLocalJson(String syncStatus) => {
    'id': id,
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'category': category,
    'syncStatus': syncStatus,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  };
}

class FavoritesRepository {
  FavoritesRepository({required this._firebaseReady, required this._uid});

  final bool _firebaseReady;
  final String? _uid;
  final _controller = StreamController<List<FavoriteMeal>>.broadcast();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteSubscription;

  Stream<List<FavoriteMeal>> watchFavorites() {
    _loadLocal();
    if (_canSync) {
      _syncPending();
      _remoteSubscription ??= _remoteCollection
          .orderBy('savedAt', descending: true)
          .snapshots()
          .listen((snapshot) async {
            final db = await LocalDatabase.instance.database;
            final batch = db.batch();
            final remoteIds = <String>{};
            for (final doc in snapshot.docs) {
              final favorite = FavoriteMeal.fromJson(doc.data());
              remoteIds.add(favorite.id);
              batch.insert(
                DatabaseTables.favorites,
                favorite.toLocalJson(SyncStatus.synced),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            await _deleteSyncedRowsMissingRemotely(
              db,
              remoteIds,
              idColumn: 'id',
            );
            await batch.commit(noResult: true);
            await _loadLocal();
          });
    }
    return _controller.stream;
  }

  Future<void> toggle(Meal meal) async {
    final db = await LocalDatabase.instance.database;
    final local = await db.query(
      DatabaseTables.favorites,
      where: 'id = ?',
      whereArgs: [meal.id],
      limit: 1,
    );
    if (local.isNotEmpty &&
        local.first['syncStatus'] != SyncStatus.pendingDelete) {
      await db.insert(
        DatabaseTables.favorites,
        FavoriteMeal.fromMeal(meal).toLocalJson(
          _canSync ? SyncStatus.pendingDelete : SyncStatus.pendingDelete,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (_canSync) {
        await _remoteCollection.doc(meal.id).delete();
        await db.delete(
          DatabaseTables.favorites,
          where: 'id = ?',
          whereArgs: [meal.id],
        );
      }
    } else {
      final favorite = FavoriteMeal.fromMeal(meal);
      await db.insert(
        DatabaseTables.favorites,
        favorite.toLocalJson(_canSync ? SyncStatus.synced : SyncStatus.pending),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (_canSync) {
        await _remoteCollection.doc(meal.id).set(favorite.toJson());
      }
    }
    await _loadLocal();
  }

  Future<void> _loadLocal() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.favorites,
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.pendingDelete],
      orderBy: 'updatedAt DESC',
    );
    _controller.add(rows.map(FavoriteMeal.fromJson).toList());
  }

  Future<void> _syncPending() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.favorites,
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.synced],
    );
    for (final row in rows) {
      final favorite = FavoriteMeal.fromJson(row);
      final doc = _remoteCollection.doc(favorite.id);
      if (row['syncStatus'] == SyncStatus.pendingDelete) {
        await doc.delete();
        await db.delete(
          DatabaseTables.favorites,
          where: 'id = ?',
          whereArgs: [favorite.id],
        );
      } else {
        await doc.set(favorite.toJson());
        await db.update(
          DatabaseTables.favorites,
          {'syncStatus': SyncStatus.synced},
          where: 'id = ?',
          whereArgs: [favorite.id],
        );
      }
    }
    await _loadLocal();
  }

  Future<void> _deleteSyncedRowsMissingRemotely(
    Database db,
    Set<String> remoteIds, {
    required String idColumn,
  }) async {
    if (remoteIds.isEmpty) {
      await db.delete(
        DatabaseTables.favorites,
        where: 'syncStatus = ?',
        whereArgs: [SyncStatus.synced],
      );
      return;
    }
    await db.delete(
      DatabaseTables.favorites,
      where:
          'syncStatus = ? AND $idColumn NOT IN (${List.filled(remoteIds.length, '?').join(',')})',
      whereArgs: [SyncStatus.synced, ...remoteIds],
    );
  }

  bool get _canSync => _firebaseReady && _uid != null;

  CollectionReference<Map<String, dynamic>> get _remoteCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('favorites');
  }

  Future<void> dispose() async {
    await _remoteSubscription?.cancel();
    await _controller.close();
  }
}

final favoritesProvider = StreamProvider<List<FavoriteMeal>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  ref.onDispose(repository.dispose);
  return repository.watchFavorites();
});
