class ReportModel {
  final String? id;
  final String projectId;
  final String? pembuatId;
  final String? penyetujuId;
  final String? jenisLaporan;
  final DateTime createdAt; // tanggal
  final String? cuaca;
  final int? jumlahPekerja;
  final String? deskripsi;
  final String statusPersetujuan;
  final String? photoUrl; // Tambahan untuk foto lapangan

  ReportModel({
    this.id,
    required this.projectId,
    this.pembuatId,
    this.penyetujuId,
    this.jenisLaporan,
    required this.createdAt,
    this.cuaca,
    this.jumlahPekerja,
    this.deskripsi,
    required this.statusPersetujuan,
    this.photoUrl,
  }) {
    assert(projectId.isNotEmpty, 'projectId tidak boleh kosong');
    assert(!createdAt.isAfter(DateTime.now()), 'Tanggal tidak valid');
  }

  factory ReportModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return ReportModel(
      id: docId ?? json['id']?.toString(),
      projectId: json['proyek_id']?.toString() ?? '',
      pembuatId: json['pembuat_id']?.toString(),
      penyetujuId: json['penyetuju_id']?.toString(),
      jenisLaporan: json['jenis_laporan'],
      createdAt: json['tanggal'] != null ? DateTime.parse(json['tanggal']) : DateTime.now(),
      cuaca: json['cuaca'],
      jumlahPekerja: json['jumlah_pekerja'],
      deskripsi: json['deskripsi'],
      statusPersetujuan: json['status_persetujuan'] ?? 'draft',
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'proyek_id': projectId,
      'pembuat_id': pembuatId,
      'penyetuju_id': penyetujuId,
      'jenis_laporan': jenisLaporan,
      'tanggal': createdAt.toIso8601String(),
      'cuaca': cuaca,
      'jumlah_pekerja': jumlahPekerja,
      'deskripsi': deskripsi,
      'status_persetujuan': statusPersetujuan,
      'photo_url': photoUrl,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
