class DocumentVersion {
  final String id;
  final String name;
  final String fileUrl;
  final String fileSize;
  final String uploadedBy;
  final String uploadedAt;
  final int version;

  const DocumentVersion({
    required this.id,
    required this.name,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.version,
  });

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'] as String,
      name: json['name'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: json['uploadedAt'] as String,
      version: json['version'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt,
        'version': version,
      };
}

class DocumentModel {
  final String id;
  final String contractId;
  final String? projectId;
  final String folderId;
  final String name;
  final String fileUrl;
  final String fileSize;
  final String uploadedBy;
  final String uploadedAt;
  final int version;
  final List<DocumentVersion> versions;

  const DocumentModel({
    required this.id,
    required this.contractId,
    this.projectId,
    required this.folderId,
    required this.name,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
    this.version = 1,
    this.versions = const [],
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      contractId: json['contractId'] as String,
      projectId: json['projectId'] as String?,
      folderId: json['folderId'] as String? ?? json['folderName'] as String? ?? '', // Fallback for old data
      name: json['name'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: json['uploadedAt'] as String,
      version: json['version'] as int? ?? 1,
      versions: (json['versions'] as List? ?? [])
          .map((v) => DocumentVersion.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contractId': contractId,
        'projectId': projectId,
        'folderId': folderId,
        'name': name,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt,
        'version': version,
        'versions': versions.map((v) => v.toJson()).toList(),
      };

  DocumentModel copyWith({
    String? name,
    String? fileUrl,
    String? fileSize,
    String? uploadedBy,
    String? uploadedAt,
    int? version,
    List<DocumentVersion>? versions,
  }) {
    return DocumentModel(
      id: id,
      contractId: contractId,
      projectId: projectId,
      folderId: folderId,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      version: version ?? this.version,
      versions: versions ?? this.versions,
    );
  }
}
