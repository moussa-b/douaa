class SubCategory {
  final int? id;
  final String name;
  final int categoryId;

  const SubCategory({
    this.id,
    required this.name,
    required this.categoryId,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      categoryId: map['category_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category_id': categoryId,
    };
  }

  SubCategory copyWith({int? id, String? name, int? categoryId}) {
    return SubCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() =>
      'SubCategory(id: $id, name: $name, categoryId: $categoryId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          categoryId == other.categoryId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ categoryId.hashCode;
}
