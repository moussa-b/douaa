class Category {
  final int? id;
  final String name;

  const Category({this.id, required this.name});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  Category copyWith({int? id, String? name}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
