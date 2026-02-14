import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

final categoryCountsProvider =
    AsyncNotifierProvider<CategoryCountsNotifier,
        Map<int, ({int subCount, int douaaCount})>>(CategoryCountsNotifier.new);

class CategoryCountsNotifier
    extends AsyncNotifier<Map<int, ({int subCount, int douaaCount})>> {
  final _db = DatabaseHelper();

  @override
  FutureOr<Map<int, ({int subCount, int douaaCount})>> build() async {
    return await _db.getCategoryCounts();
  }
}

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  final _db = DatabaseHelper();

  @override
  FutureOr<List<Category>> build() async {
    return await _db.getCategories();
  }

  Future<void> addCategory(String name) async {
    await _db.insertCategory(Category(name: name));
    state = AsyncData(await _db.getCategories());
    ref.invalidate(favoriteCategoriesProvider);
    ref.invalidate(categoryCountsProvider);
  }

  Future<void> updateCategory(Category category) async {
    await _db.updateCategory(category);
    state = AsyncData(await _db.getCategories());
    ref.invalidate(favoriteCategoriesProvider);
    ref.invalidate(categoryCountsProvider);
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    state = AsyncData(await _db.getCategories());
    ref.invalidate(favoriteCategoriesProvider);
    ref.invalidate(categoryCountsProvider);
  }

  Future<void> refresh() async {
    state = AsyncData(await _db.getCategories());
  }
}

// ── Favorite Categories ──

final favoriteCategoriesProvider =
    AsyncNotifierProvider<FavoriteCategoriesNotifier, List<Category>>(
  FavoriteCategoriesNotifier.new,
);

class FavoriteCategoriesNotifier extends AsyncNotifier<List<Category>> {
  final _db = DatabaseHelper();

  @override
  FutureOr<List<Category>> build() async {
    return await _db.getFavoriteCategories();
  }

  Future<void> refresh() async {
    state = AsyncData(await _db.getFavoriteCategories());
  }
}
