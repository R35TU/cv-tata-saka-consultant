class ProjectModel {
  final String? id;
  final String title;
  final String? perusahaanId;
  final String? pemilikProyek;
  final String? sumberDana;
  final String location;
  final String? imagePath;
  final String? tanggalMulai;
  final String? targetSelesai;
  final int progressRencana;
  final int progressAktual;
  final String status;

  ProjectModel({
    this.id,
    required this.title,
    this.perusahaanId,
    this.pemilikProyek,
    this.sumberDana,
    required this.location,
    this.imagePath,
    this.tanggalMulai,
    this.targetSelesai,
    required this.progressRencana,
    required this.progressAktual,
    required this.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return ProjectModel(
      id: docId ?? json['id']?.toString(),
      title: json['nama_proyek'] ?? '',
      perusahaanId: json['perusahaan_id']?.toString(),
      pemilikProyek: json['pemilik_proyek'],
      sumberDana: json['sumber_dana'],
      location: json['lokasi'] ?? '',
      imagePath: json['gambar_url'] ?? 'assets/images/placeholder.png',
      tanggalMulai: json['tanggal_mulai'],
      targetSelesai: json['target_selesai'],
      progressRencana: json['progress_rencana'] ?? 0,
      progressAktual: json['progress_aktual'] ?? 0,
      status: json['status'] ?? 'Perencanaan',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nama_proyek': title,
      'perusahaan_id': perusahaanId,
      'pemilik_proyek': pemilikProyek,
      'sumber_dana': sumberDana,
      'lokasi': location,
      'gambar_url': imagePath,
      'tanggal_mulai': tanggalMulai,
      'target_selesai': targetSelesai,
      'progress_rencana': progressRencana,
      'progress_aktual': progressAktual,
      'status': status,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
