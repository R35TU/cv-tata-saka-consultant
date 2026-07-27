class ProjectModel {
  final String id;
  final String name;
  final String location;
  final String status; // "Progres" | "Selesai"
  final double physicalProgress; // 0.0 to 1.0
  final double financialProgress; // 0.0 to 1.0
  final String imageUrl;
  final String description;
  final String owner; // e.g. PT. Maju Mundur Jaya
  final String supervisor; // e.g. CV. Tata Saka Consultant
  final String createdAt;
  
  // Extra detailed fields for the Umum tab
  final String startDate; // yyyy-MM-dd or human readable
  final String endDate; // yyyy-MM-dd or human readable
  final String ownerDetail; // e.g. Pemerintah Kabupaten Banyumas (Pemilik Proyek)
  final String fundingSource; // e.g. APBD 2026
  final bool isArchived;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.physicalProgress,
    required this.financialProgress,
    required this.imageUrl,
    required this.description,
    required this.owner,
    required this.supervisor,
    required this.createdAt,
    this.startDate = '2026-01-01',
    this.endDate = '2026-06-30',
    this.ownerDetail = 'Pemerintah Daerah',
    this.fundingSource = 'APBD 2026',
    this.isArchived = false,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      physicalProgress: (json['physicalProgress'] as num).toDouble(),
      financialProgress: (json['financialProgress'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      owner: json['owner'] as String,
      supervisor: json['supervisor'] as String,
      createdAt: json['createdAt'] as String,
      startDate: json['startDate'] as String? ?? '2026-01-01',
      endDate: json['endDate'] as String? ?? '2026-06-30',
      ownerDetail: json['ownerDetail'] as String? ?? 'Pemerintah Daerah',
      fundingSource: json['fundingSource'] as String? ?? 'APBD 2026',
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'status': status,
        'physicalProgress': physicalProgress,
        'financialProgress': financialProgress,
        'imageUrl': imageUrl,
        'description': description,
        'owner': owner,
        'supervisor': supervisor,
        'createdAt': createdAt,
        'startDate': startDate,
        'endDate': endDate,
        'ownerDetail': ownerDetail,
        'fundingSource': fundingSource,
        'isArchived': isArchived,
      };

  ProjectModel copyWith({
    String? name,
    String? location,
    String? status,
    double? physicalProgress,
    double? financialProgress,
    String? imageUrl,
    String? description,
    String? owner,
    String? supervisor,
    String? startDate,
    String? endDate,
    String? ownerDetail,
    String? fundingSource,
    bool? isArchived,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      physicalProgress: physicalProgress ?? this.physicalProgress,
      financialProgress: financialProgress ?? this.financialProgress,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      supervisor: supervisor ?? this.supervisor,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      ownerDetail: ownerDetail ?? this.ownerDetail,
      fundingSource: fundingSource ?? this.fundingSource,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
