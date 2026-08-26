class PhotoDocumentationModel {
  final String id;
  final String physicalActivityId;
  final String reportId;
  final String photoUrl;
  final String description;
  final String uploadedAt;

  const PhotoDocumentationModel({
    required this.id,
    required this.physicalActivityId,
    required this.reportId,
    required this.photoUrl,
    required this.description,
    required this.uploadedAt,
  });

  factory PhotoDocumentationModel.fromJson(Map<String, dynamic> json) {
    return PhotoDocumentationModel(
      id: json['id'] as String,
      physicalActivityId: json['physicalActivityId'] as String,
      reportId: json['reportId'] as String? ?? '',
      photoUrl: json['photoUrl'] as String,
      description: json['description'] as String,
      uploadedAt: json['uploadedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'physicalActivityId': physicalActivityId,
        'reportId': reportId,
        'photoUrl': photoUrl,
        'description': description,
        'uploadedAt': uploadedAt,
      };
}
