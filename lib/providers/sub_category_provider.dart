import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/sub_category.dart';

final subCategoryListProvider =
    AsyncNotifierProvider.family<SubCategoryListNotifier, List<SubCategory>, int>(
  SubCategoryListNotifier.new,
);

class SubCategoryListNotifier extends AsyncNotifier<List<SubCategory>> {
  SubCategoryListNotifier(this.categoryId);
  final int categoryId;
  final _db = DatabaseHelper();

  @override
  FutureOr<List<SubCategory>> build() async {
    return await _db.getSubCategoriesByCategoryId(categoryId);
  }

  Future<int> addSubCategory(String name) async {
    final id = await _db.insertSubCategory(
      SubCategory(name: name, categoryId: categoryId),
    );
    state = AsyncData(await _db.getSubCategoriesByCategoryId(categoryId));
    return id;
  }

  Future<void> deleteSubCategory(int id) async {
    await _db.deleteSubCategory(id);
    state = AsyncData(await _db.getSubCategoriesByCategoryId(categoryId));
  }

  Future<void> refresh() async {
    state = AsyncData(await _db.getSubCategoriesByCategoryId(categoryId));
  }
}
