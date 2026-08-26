class ContractModel {
  final String id;
  final String type; // "Pengawasan Teknis" | "Perencanaan Teknis"
  final String name;
  final String location;
  final String status; // "Progres" | "Selesai"
  final String imageUrl;
  final String description;
  final String owner; // Kontraktor for parent? Wait, the plan said preserve owner
  final String supervisor; // Konsultan
  final String createdAt;
  final String startDate; // yyyy-MM-dd
  final String endDate; // yyyy-MM-dd
  final List<String> dinas; // Pemilik Proyek (Dinas)
  final String fundingSource; // Sumber Dana
  final bool isArchived;

  const ContractModel({
    required this.id,
    required this.type,
    required this.name,
    required this.location,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.owner,
    required this.supervisor,
    required this.createdAt,
    this.startDate = '2026-01-01',
    this.endDate = '2026-06-30',
    this.dinas = const ['Pemerintah Daerah'],
    this.fundingSource = 'APBD 2026',
    this.isArchived = false,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'Pengawasan Teknis',
      name: json['name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      owner: json['owner'] as String,
      supervisor: json['supervisor'] as String,
      createdAt: json['createdAt'] as String,
      startDate: json['startDate'] as String? ?? '2026-01-01',
      endDate: json['endDate'] as String? ?? '2026-06-30',
      dinas: (json['dinas'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['Pemerintah Daerah'],
      fundingSource: json['fundingSource'] as String? ?? 'APBD 2026',
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'location': location,
        'status': status,
        'imageUrl': imageUrl,
        'description': description,
        'owner': owner,
        'supervisor': supervisor,
        'createdAt': createdAt,
        'startDate': startDate,
        'endDate': endDate,
        'dinas': dinas,
        'fundingSource': fundingSource,
        'isArchived': isArchived,
      };

  ContractModel copyWith({
    String? type,
    String? name,
    String? location,
    String? status,
    String? imageUrl,
    String? description,
    String? owner,
    String? supervisor,
    String? startDate,
    String? endDate,
    List<String>? dinas,
    String? fundingSource,
    bool? isArchived,
  }) {
    return ContractModel(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      supervisor: supervisor ?? this.supervisor,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dinas: dinas ?? this.dinas,
      fundingSource: fundingSource ?? this.fundingSource,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class ProjectModel {
  final String id;
  final String contractId;
  final String name;
  final String location;
  final String contractor;
  final String description;
  final String status;
  final double physicalProgress;
  final double financialProgress;

  const ProjectModel({
    required this.id,
    required this.contractId,
    required this.name,
    required this.location,
    required this.contractor,
    required this.description,
    required this.status,
    required this.physicalProgress,
    required this.financialProgress,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      contractId: json['contractId'] as String? ?? json['activityId'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      contractor: json['contractor'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      physicalProgress: (json['physicalProgress'] as num).toDouble(),
      financialProgress: (json['financialProgress'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contractId': contractId,
        'name': name,
        'location': location,
        'contractor': contractor,
        'description': description,
        'status': status,
        'physicalProgress': physicalProgress,
        'financialProgress': financialProgress,
      };

  ProjectModel copyWith({
    String? name,
    String? location,
    String? contractor,
    String? description,
    String? status,
    double? physicalProgress,
    double? financialProgress,
  }) {
    return ProjectModel(
      id: id,
      contractId: contractId,
      name: name ?? this.name,
      location: location ?? this.location,
      contractor: contractor ?? this.contractor,
      description: description ?? this.description,
      status: status ?? this.status,
      physicalProgress: physicalProgress ?? this.physicalProgress,
      financialProgress: financialProgress ?? this.financialProgress,
    );
  }
}
