import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/douaa.dart';
import 'category_provider.dart';

final douaaListProvider =
    AsyncNotifierProvider.family<DouaaListNotifier, List<Douaa>, int>(
  DouaaListNotifier.new,
);

class DouaaListNotifier extends AsyncNotifier<List<Douaa>> {
  DouaaListNotifier(this.categoryId);
  final int categoryId;
  final _db = DatabaseHelper();

  @override
  FutureOr<List<Douaa>> build() async {
    return await _db.getDouaaByCategoryId(categoryId);
  }

  Future<void> addDouaa(Douaa douaa) async {
    await _db.insertDouaa(douaa);
    state = AsyncData(await _db.getDouaaByCategoryId(categoryId));
  }

  Future<void> updateDouaa(Douaa douaa) async {
    await _db.updateDouaa(douaa);
    state = AsyncData(await _db.getDouaaByCategoryId(categoryId));
  }

  Future<void> toggleFavorite(int douaaId, bool isFavorite) async {
    await _db.toggleFavorite(douaaId, isFavorite);
    state = AsyncData(await _db.getDouaaByCategoryId(categoryId));
    // Refresh favorite categories since a toggle may change them
    ref.invalidate(favoriteCategoriesProvider);
  }

  Future<void> deleteDouaa(int id) async {
    await _db.deleteDouaa(id);
    state = AsyncData(await _db.getDouaaByCategoryId(categoryId));
    ref.invalidate(favoriteCategoriesProvider);
  }

  Future<void> refresh() async {
    state = AsyncData(await _db.getDouaaByCategoryId(categoryId));
  }
}
