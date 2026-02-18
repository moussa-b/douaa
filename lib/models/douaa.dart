class Douaa {
  final int? id;
  final int categoryId;
  final int? subCategoryId;
  final String douaaAr;
  final String? douaaFr;
  final String? reference;
  final String? tags;
  final bool isFavorite;
  final int readCount;
  final String? subCategoryName; // From LEFT JOIN, not stored

  const Douaa({
    this.id,
    required this.categoryId,
    this.subCategoryId,
    required this.douaaAr,
    this.douaaFr,
    this.reference,
    this.tags,
    this.isFavorite = false,
    this.readCount = 0,
    this.subCategoryName,
  });

  factory Douaa.fromMap(Map<String, dynamic> map) {
    return Douaa(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int? ?? 0,
      subCategoryId: map['sub_category_id'] as int?,
      douaaAr: map['douaa_ar'] as String? ?? '',
      douaaFr: map['douaa_fr'] as String?,
      reference: map['reference'] as String?,
      tags: map['tags'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      readCount: map['read_count'] as int? ?? 0,
      subCategoryName: map['sub_category_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'douaa_ar': douaaAr,
      'douaa_fr': douaaFr,
      'reference': reference,
      'tags': tags,
      'is_favorite': isFavorite ? 1 : 0,
      'read_count': readCount,
    };
  }

  Douaa copyWith({
    int? id,
    int? categoryId,
    int? subCategoryId,
    String? douaaAr,
    String? douaaFr,
    String? reference,
    String? tags,
    bool? isFavorite,
    int? readCount,
    String? subCategoryName,
  }) {
    return Douaa(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      douaaAr: douaaAr ?? this.douaaAr,
      douaaFr: douaaFr ?? this.douaaFr,
      reference: reference ?? this.reference,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      readCount: readCount ?? this.readCount,
      subCategoryName: subCategoryName ?? this.subCategoryName,
    );
  }

  @override
  String toString() =>
      'Douaa(id: $id, categoryId: $categoryId, douaaAr: ${douaaAr.substring(0, douaaAr.length > 30 ? 30 : douaaAr.length)}...)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Douaa &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
