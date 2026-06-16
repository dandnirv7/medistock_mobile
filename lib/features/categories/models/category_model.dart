class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.medicineCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int medicineCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      medicineCount: (json['medicineCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'isActive': isActive,
        'medicineCount': medicineCount,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    int? medicineCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      medicineCount: medicineCount ?? this.medicineCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
