class LaporanModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String status;
  final String createdAt;
  final String? namaPelapor; 

  LaporanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.createdAt,
    this.namaPelapor,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      status: json['status'],
      createdAt: json['created_at'],
      namaPelapor: json['nama_lengkap'], 
    );
  }
}