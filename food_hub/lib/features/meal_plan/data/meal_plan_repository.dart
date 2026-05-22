import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/database_tables.dart';
import '../../../core/firebase/firebase_status.dart';
import '../../../core/storage/local_database.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../favorites/data/favorites_repository.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return MealPlanRepository(
    firebaseReady: ref.watch(firebaseReadyProvider),
    uid: user?.uid,
  );
});

class MealPlanEntry {
  const MealPlanEntry({
    required this.day,
    required this.slot,
    required this.mealId,
    required this.name,
  });

  final String day;
  final String slot;
  final String mealId;
  final String name;

  String get id => '$day-$slot';

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) {
    return MealPlanEntry(
      day: json['day']?.toString() ?? '',
      slot: json['slot']?.toString() ?? '',
      mealId: json['mealId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, Object?> toRemoteJson() => {
    'day': day,
    'slot': slot,
    'mealId': mealId,
    'name': name,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, Object?> toLocalJson(String syncStatus) => {
    'id': id,
    'day': day,
    'slot': slot,
    'mealId': mealId,
    'name': name,
    'syncStatus': syncStatus,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  };
}

class MealPlanRepository {
  MealPlanRepository({required this._firebaseReady, required this._uid});

  final bool _firebaseReady;
  final String? _uid;
  final _controller = StreamController<List<MealPlanEntry>>.broadcast();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteSubscription;

  Stream<List<MealPlanEntry>> watchPlan() {
    _loadLocal();
    if (_canSync) {
      _syncPending();
      _remoteSubscription ??= _remoteCollection.snapshots().listen((
        snapshot,
      ) async {
        final db = await LocalDatabase.instance.database;
        final batch = db.batch();
        final remoteIds = <String>{};
        for (final doc in snapshot.docs) {
          final entry = MealPlanEntry.fromJson(doc.data());
          remoteIds.add(entry.id);
          batch.insert(
            DatabaseTables.mealPlan,
            entry.toLocalJson(SyncStatus.synced),
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

  Future<void> setSlot(String day, String slot, FavoriteMeal meal) async {
    final entry = MealPlanEntry(
      day: day,
      slot: slot,
      mealId: meal.id,
      name: meal.name,
    );
    final db = await LocalDatabase.instance.database;
    await db.insert(
      DatabaseTables.mealPlan,
      entry.toLocalJson(_canSync ? SyncStatus.synced : SyncStatus.pending),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (_canSync) {
      await _remoteCollection.doc(entry.id).set(entry.toRemoteJson());
    }
    await _loadLocal();
  }

  Future<void> _loadLocal() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.mealPlan,
      orderBy: 'day ASC, slot ASC',
    );
    _controller.add(rows.map(MealPlanEntry.fromJson).toList());
  }

  Future<void> _syncPending() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.mealPlan,
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.synced],
    );
    for (final row in rows) {
      final entry = MealPlanEntry.fromJson(row);
      await _remoteCollection.doc(entry.id).set(entry.toRemoteJson());
      await db.update(
        DatabaseTables.mealPlan,
        {'syncStatus': SyncStatus.synced},
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
    await _loadLocal();
  }

  Future<void> _deleteSyncedRowsMissingRemotely(
    Database db,
    Set<String> remoteIds,
  ) async {
    if (remoteIds.isEmpty) {
      await db.delete(
        DatabaseTables.mealPlan,
        where: 'syncStatus = ?',
        whereArgs: [SyncStatus.synced],
      );
      return;
    }
    await db.delete(
      DatabaseTables.mealPlan,
      where:
          'syncStatus = ? AND id NOT IN (${List.filled(remoteIds.length, '?').join(',')})',
      whereArgs: [SyncStatus.synced, ...remoteIds],
    );
  }

  bool get _canSync => _firebaseReady && _uid != null;

  CollectionReference<Map<String, dynamic>> get _remoteCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('meal_plan');
  }

  Future<void> dispose() async {
    await _remoteSubscription?.cancel();
    await _controller.close();
  }
}

final mealPlanProvider = StreamProvider<List<MealPlanEntry>>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  ref.onDispose(repository.dispose);
  return repository.watchPlan();
});
