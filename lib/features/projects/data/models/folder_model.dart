class FolderModel {
  final String id;
  final String contractId;
  final String? projectId;
  final String name;
  final bool isDefault;

  const FolderModel({
    required this.id,
    required this.contractId,
    this.projectId,
    required this.name,
    this.isDefault = false,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      contractId: json['contractId'] as String,
      projectId: json['projectId'] as String?,
      name: json['name'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contractId': contractId,
        'projectId': projectId,
        'name': name,
        'isDefault': isDefault,
      };

  FolderModel copyWith({
    String? name,
    bool? isDefault,
  }) {
    return FolderModel(
      id: id,
      contractId: contractId,
      projectId: projectId,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
