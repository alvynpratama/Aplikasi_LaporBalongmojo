// File: lib/models/berita_model.dart
class BeritaModel {
  final int id;
  final String judul;
  final String isi;
  final String createdAt;
  final String? authorName;
  // ignore: non_constant_identifier_names
  final String? gambar_url; // <-- Tambahkan ignore di atas ini

  BeritaModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.createdAt,
    this.authorName,
    // ignore: non_constant_identifier_names
    this.gambar_url, // <-- Tambahkan ignore di atas ini
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      createdAt: json['created_at'],
      authorName: json['author_name'],
      gambar_url: json['gambar_url'],
    );
  }
}