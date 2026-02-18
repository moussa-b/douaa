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
        Map<int, ({int subCount, int douaaCount, int invokedCount})>>(CategoryCountsNotifier.new);

class CategoryCountsNotifier
    extends AsyncNotifier<Map<int, ({int subCount, int douaaCount, int invokedCount})>> {
  final _db = DatabaseHelper();

  @override
  FutureOr<Map<int, ({int subCount, int douaaCount, int invokedCount})>> build() async {
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
    final maxOrder = await _db.getMaxCategorySortOrder();
    await _db.insertCategory(Category(name: name, sortOrder: maxOrder + 1));
    state = AsyncData(await _db.getCategories());
    ref.invalidate(favoriteCategoriesProvider);
    ref.invalidate(categoryCountsProvider);
  }

  Future<void> reorderCategories(List<Category> ordered) async {
    final ids = ordered.where((c) => c.id != null).map((c) => c.id!).toList();
    if (ids.isEmpty) return;
    await _db.updateCategorySortOrders(ids);
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
