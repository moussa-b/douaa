class Category {
  final int? id;
  final String name;
  final int? sortOrder;

  const Category({this.id, required this.name, this.sortOrder});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      sortOrder: map['sort_order'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    };
  }

  Category copyWith({int? id, String? name, int? sortOrder}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name, sortOrder: $sortOrder)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ sortOrder.hashCode;
}
